FROM ubuntu:18.04


RUN apt-get update && \
    apt-get install -y \
        autoconf \
        automake \
        g++ \
        gcc \
        gfortran \
        make \
        nano \
    && apt-get clean all \
    && rm -rf /var/lib/apt/lists/*

VOLUME ["/data"]
WORKDIR /data

CMD ["/bin/bash"]