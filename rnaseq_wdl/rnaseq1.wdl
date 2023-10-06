version 1.0
workflow rnaseq
{

	
	input {
		String dir_fastq = "/home/user08/rna-seq/rawdata"
		Boolean Paired	= false
		
		}

	call getrawdata {

	input:
	path = dir_fastq
			}
	scatter(j in getrawdata.paths)
	{
	call fastqc {
	input: 
	fastq_files = j
	
		}
	
	}
	



	if (!Paired){
	scatter(i in getrawdata.paths){
	call trim_SE{

	input:
	fastq_file = i
		}
		}			
	}
	

	if(Paired) {
	scatter(i in getrawdata.paths){
	String file_name = basename(i, ".fastq.gz")
		
	
	call getPaired{
	
	input:
	path = dir_fastq,	
	sampleName = file_name
		}	
	

	call trim_PE{	
        input:
	fastq_file_R1 = "/home/user08/rna-seq/rawdata/S1.R1.fastq.gz",
        fastq_file_R2 = "/home/user08/rna-seq/rawdata/S1.R2.fastq.gz"

                }
       		                      
		 		}

		}

	output {

	Array[File] paths_out = getrawdata.paths
	Array[File]? R1_path = getPaired.R1_Path
	Array[File]? R2_path = getPaired.R2_Path
	Array[File] fastqc_out = fastqc.fastqc_out
	Array[File]? trim_SE_out = trim_SE.filtered_data
	Array[File]? trim_PE_R1_Paired = trim_PE.filtered_data_R1_Paired 
	Array[File]? trim_PE_R1_Unpaired = trim_PE.filtered_data_R1_Unpaired
	Array[File]? trim_PE_R2_Paired = trim_PE.filtered_data_R2_Paired
	Array[File]? trim_PE_R2_Unpaired = trim_PE.filtered_data_R2_Unpaired

		}

}
task getrawdata {
input {
String path 
}

command <<<
ls ~{path}/*fastq.gz > rawdatapath.txt

>>>

output{
Array[File]paths=read_lines("rawdatapath.txt")
}

}


task getPaired {
input {
String path
String sampleName
}

command <<<
cd ~{path}
ls ~{sampleName}.fastq.gz| awk -F'.' '{print $1}' > result | ls $PWD/$result*.fastq.gz  > path
v1=`head -n1 path` | echo $v1 > ~{sampleName}.txt 
v2=`tail -n1 path` | echo $v2 > ~{sampleName}.txt
>>>
	output{

	File R1_Path=read_lines("~{sampleName}.txt")
	File R2_Path=read_lines("~{sampleName}.txt")

	}
}
task fastqc
{

	input {

	File fastq_files
	
		}
String filename = basename(fastq_files, ".fastq.gz")

runtime{
docker: "mohammedfarahat/rna-seq:fastqc"
}

command {
	fastqc ~{sep=' ' fastq_files} -o .
		
	}
output {
	File fastqc_out = "~{filename}_fastqc.html"
	}

}

task trim_SE
{
	input {

	File fastq_file
	
		}
String filename = basename(fastq_file, ".fastq.gz")
runtime{
docker: "mohammedfarahat/rna-seq:trimmomatic"
}


command{

java -jar /opt/Trimmomatic-0.39/trimmomatic-0.39.jar SE -phred33 \
 ~{fastq_file} ~{filename}.out.fastq.gz ILLUMINACLIP:TruSeq3-SE:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36
}

output{

File filtered_data = "~{filename}.out.fastq.gz"

	}	

}
task trim_PE
{
        input {

        File fastq_file_R1
	File fastq_file_R2

                }
String filename_R1 = basename(fastq_file_R1, ".fastq.gz")
String filename_R2 = basename(fastq_file_R2, ".fastq.gz")
runtime{
docker: "mohammedfarahat/rna-seq:trimmomatic"
}


command{

java -jar /opt/Trimmomatic-0.39/trimmomatic-0.39.jar PE \
 ~{fastq_file_R1} ~{fastq_file_R2} \
~{filename_R1}.out.paired.fastq.gz \
~{filename_R1}.out.unpaired.fastq.gz \
~{filename_R2}.out.paired.fastq.gz \
~{filename_R2}.out.unpaired.fastq.gz \
ILLUMINACLIP:TruSeq3-PE.fa:2:30:10:2:True LEADING:3 TRAILING:3 MINLEN:36
}

output{

File filtered_data_R1_Paired = "~{filename_R1}.out.paired.fastq.gz" 
File filtered_data_R1_Unpaired = "~{filename_R1}.out.unpaired.fastq.gz"
File filtered_data_R2_Paired = "~{filename_R2}.out.paired.fastq.gz"
File filtered_data_R2_Unpaired = "~{filename_R2}.out.unpaired.fastq.gz"

}


}























