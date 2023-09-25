FROM amazonlinux:latest


ARG FLYE_VER="2.9"

RUN yum -y install unzip aws-cli
RUN yum -y install less groff

RUN yum -y install tar wget git curl make gcc gcc-c++
RUN yum -y install zlib-devel bzip2



RUN yum -y install \

 python \
 python-pip \
 python-setuptools \
 zlib1g-dev 

 
 

# install flye 
RUN wget https://github.com/fenderglass/Flye/archive/${FLYE_VER}.tar.gz && \
 tar -xvf ${FLYE_VER}.tar.gz && \
 rm ${FLYE_VER}.tar.gz && \
 cd Flye-${FLYE_VER} && \
 python setup.py build && \
 python setup.py install 
 
 
 # Install samtools
RUN cd /usr/local/bin && \
    wget https://github.com/samtools/samtools/releases/download/1.7/samtools-1.7.tar.bz2 && \
    tar xvf samtools-1.7.tar.bz2 && \
    cd samtools-1.7 && \
    ./configure --without-curses --disable-lzma --disable-bz2 --prefix=/usr/local/bin && \
    make && \
    make install && \
    ln -s $PWD/samtools /usr/local/bin/
