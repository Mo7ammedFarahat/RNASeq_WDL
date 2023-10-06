# Using official ubuntu image as a parent image
FROM ubuntu:latest


# Install OpenJDK-8
RUN apt-get update && \
apt-get install -y unzip \
	build-essential \
	curl \
	wget \
	debconf-utils \
	software-properties-common \
&& apt-add-repository ppa:openjdk-r/ppa \
&& apt-get install -y openjdk-8-jre \
&& rm -rf /var/lib/apt/lists/*

# Download FastQC
RUN cd /opt \
	&& wget http://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.8.zip \
	&& unzip fastqc_v0.11.8.zip \
    	&& chmod 755 FastQC/fastqc \
    	&& rm /opt/fastqc_v0.11.8.zip

ENV PATH=/opt/FastQC:$PATH




