#!/bin/bash
set -e
set -u
set -o pipefail
set -x

sample_name=$(basename -s .fastq.gz "$1" )
echo ${sample_name}
bioawk -c fastx '{print ">"$name; print $seq }' ${sample_name}.fastq.gz > ${sample_name}.fa



# run the get_fa.sh in parallel with find and xargs
## -t is to echo back the command 
##find . -name "*.fastq.gz" | xargs -n 1 -P 4  -t  bash get_fa.sh


## read1=B-1002_XT_H12_R1_001.fastq.gz
## downsample=100
## seqtk sample -s 14 ${read1} $downsample | gzip > seqB.1000.fastq.gz