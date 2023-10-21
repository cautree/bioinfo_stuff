#!/bin/bash

## -n is to get rid of extra line after echo
s3_path="seqwell-fastq"
run_name="20231019_MiSeq-Appa"
plates=("ASU-384-Q1_FASTQ" "ASU-384-Q2_FASTQ" "ASU-384-Q3_FASTQ" "ASU-384-Q4_FASTQ")

echo -n old_id  > old_name
for plate_name in "${plates[@]}"
do
  aws s3 ls s3://${s3_path}/${run_name}/${plate_name}/ | awk '{$1=$1}1' OFS="," | cut -f 4 -d "," >> old_name
done