FROM amazonlinux:latest

RUN yum -y install unzip aws-cli
RUN yum -y install less groff

RUN yum -y install tar wget git curl make gcc 
RUN yum -y install zlib-devel bzip2

RUN wget https://github.com/lh3/minimap2/releases/download/v2.26/minimap2-2.26.tar.bz2 && tar -xf minimap2-2.26.tar.bz2 \
&& cd minimap2-2.26 && make && cp minimap2 /usr/local/bin/ && chmod +x /usr/local/bin/minimap2


# Install samtools
RUN cd /usr/local/bin && \
    wget https://github.com/samtools/samtools/releases/download/1.7/samtools-1.7.tar.bz2 && \
    tar xvf samtools-1.7.tar.bz2 && \
    cd samtools-1.7 && \
    ./configure --without-curses --disable-lzma --disable-bz2 --prefix=/usr/local/bin && \
    make && \
    make install && \
    ln -s $PWD/samtools /usr/local/bin/
