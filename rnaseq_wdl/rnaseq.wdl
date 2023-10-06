version 1.0
workflow rnaseq
{
	input {
		String dir_fastq = "/home/user08/rna-seq/rawdata"
		}

	call getrawdata {

	input:
	path = dir_fastq
			}
	
	call fastqc {
	input: 
	fastq_files = getrawdata.paths
	
		}
	scatter(i in getrawdata.paths){

	call trim{

	input:
	fastq_file = i
		}

				}
	output {

	Array[File] paths_out = getrawdata.paths
	File fastqc_out = fastqc.fastqc_out
	Array[File] trim_out = trim.filtered_data
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

task fastqc
{

	input {

	Array[File] fastq_files
	
		}

runtime{
docker: "mohammedfarahat/rna-seq:fastqc"
}

command {
	fastqc ~{sep=' ' fastq_files} -o .
		
	}
output {
	File fastqc_out = "S1_fastqc.html"
	}

}

task trim
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























