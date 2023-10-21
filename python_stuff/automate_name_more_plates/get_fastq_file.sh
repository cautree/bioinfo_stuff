#!/bin/bash

#Plate 1 ASU-Ctrl_FASTQ:  s3://seqwell-fastq/20231017_MiSeq-Yoda/ASU-Ctrl_FASTQ/
#Plate 2 ASU-T1_FASTQ:  s3://seqwell-fastq/20231017_MiSeq-Yoda/ASU-T1_FASTQ/
s3_path="seqwell-fastq"
run_name="20231019_MiSeq-Appa"
plates=("ASU-384-Q1_FASTQ" "ASU-384-Q2_FASTQ" "ASU-384-Q3_FASTQ" "ASU-384-Q4_FASTQ")

for plate_name in "${plates[@]}"
do
  aws s3 cp s3://${s3_path}/${run_name}/${plate_name}/  fastq --recursive
done