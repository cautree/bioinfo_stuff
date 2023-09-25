FROM amazonlinux:latest

RUN yum -y install unzip aws-cli
RUN yum -y install less groff

RUN yum -y install wget tar gzip gunzip bzip2
RUN yum -y install make libstdc++-devel zlib-devel
RUN yum -y install util-linux
RUN yum -y install procps

RUN yum install -y python3
RUN yum install -y python3-pip
RUN pip3 install nanofilt