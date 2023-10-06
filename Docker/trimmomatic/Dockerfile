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
	&& wget http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/Trimmomatic-0.39.zip \
	&& unzip Trimmomatic-0.39.zip  \
    	&& rm /opt/Trimmomatic-0.39.zip

ENV PATH=/opt/Trimmomatic-0.39:$PATH




