#!/bin/bash

read1=Undetermined_S0_L003_R2_001.fastq.gz
seqtk sample -s 14 ${read1} 0.001 | gzip > Undetermined_S0_L003_R2_001.001.fastq.gz

zcat Undetermined_S0_L003_R2_001.001.fastq.gz \
  | awk 'NR%4==1' \
  | awk -F":" '{print $(NF)}' \
  | sort \
  | uniq -c | sort -k1,1nr > barcodes.txt
  
#zcat $a | awk 'NR%4==1' | awk -F":" '{print $(NF)}' | sort | uniq -c | sort -k1,1nr > barcodes.txt
  
  
