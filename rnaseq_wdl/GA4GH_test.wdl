version 1.0

workflow rnaseq {
  input {
    String dir_fastq = "/users/mohammedfarahat/ContainersWorkshop/rna-seq/rawdata"
  }

  call getrawdata {
    input:
      path = dir_fastq
  }

  scatter(i in getrawdata.paths) {
    call fastqc {
      input:
        fastqc_file = i
    }

    call trim {
      input:
        trim_file = i
    }
  }

  output {
    Array[File] paths_out = getrawdata.paths
    Array[File] fastqc_out = fastqc.fastqc_out
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

  output {
    Array[File] paths = read_lines("rawdatapath.txt")
  }
}

task fastqc {
  input {
    File fastqc_file
  }

  String filename = basename(fastqc_file, ".fastq.gz")

  command {
    fastqc ~{fastqc_file} -o .
  }

  output {
    File fastqc_out = "${filename}_fastqc.html"
  }

  runtime {
    docker: "mohammedfarahat/rna-seq:fastqc"
  }
}

task trim {
  input {
    File trim_file
  }

  String filename = basename(trim_file, ".fastq.gz")

  command {
    java -jar /opt/Trimmomatic-0.39/trimmomatic-0.39.jar SE -phred33 \
    ~{trim_file} ${filename}.out.fastq.gz ILLUMINACLIP:TruSeq3-SE:2:30:10 \
    LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36
  }

  output {
    File filtered_data = "${filename}.out.fastq.gz"
  }

  runtime {
    docker: "mohammedfarahat/rna-seq:trimmomatic"
  }
}
