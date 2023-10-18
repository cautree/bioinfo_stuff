#!/bin/bash

## -n is to get rid of extra line after echo
s3_path="seqwell-fastq"
run_name="20231017_MiSeq-Yoda"
plates=("ASU-Ctrl_FASTQ" "ASU-T1_FASTQ")

echo -n old_id  > old_name
for plate_name in "${plates[@]}"
do
  aws s3 ls s3://${s3_path}/${run_name}/${plate_name}/ | awk '{$1=$1}1' OFS="," | cut -f 4 -d "," >> old_name
done