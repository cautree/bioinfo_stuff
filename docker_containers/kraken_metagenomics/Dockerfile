FROM amazonlinux:latest

RUN yum -y install unzip aws-cli zip gzip make gcc gcc-c++
RUN yum -y install less groff libomp clang-9

RUN yum -y install tar wget



RUN cd /usr/local/bin && \
  wget https://www.cpan.org/src/5.0/perl-5.28.1.tar.gz && \
  tar xzf perl-5.28.1.tar.gz && \
  cd perl-5.28.1 && \
  ./Configure -de && \
  make && \
  make install

RUN mkdir -p kraken2


RUN wget http://github.com/DerrickWood/kraken2/archive/v2.0.8-beta.tar.gz && \
  tar xvf v2.0.8-beta.tar.gz  && \
  cd kraken2-2.0.8-beta && \
  ./install_kraken2.sh kraken2 && \
  cp /kraken2-2.0.8-beta/kraken2/kraken2 /usr/local/bin/ && \
  cp /kraken2-2.0.8-beta/kraken2/kraken2-build /usr/local/bin/ && \
  cp /kraken2-2.0.8-beta/kraken2/kraken2-inspect /usr/local/bin/
 

RUN wget https://github.com/jenniferlu717/Bracken/archive/v2.7.tar.gz && \
  tar xvf v2.7.tar.gz  && \
  cd Bracken-2.7 && \
  cd src && \
  make && \
  cp ../bracken-build /usr/local/bin/ && \
  cp ../bracken /usr/local/bin/ && \
  cp -r ../src/ /usr/local/bin/

  