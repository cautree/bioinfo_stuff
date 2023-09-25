#!/bin/bash

rm -r demux_report
mkdir demux_report
rm -f file_to_get


aws s3 ls s3://seqwell-fastq/$1/ | grep -e txt | awk '{$1=$1}1' OFS="," | cut -f 4 -d "," > file_to_get
aws s3 ls s3://seqwell-fastq/$1/ | grep -e xlsx | awk '{$1=$1}1' OFS="," | cut -f 4 -d "," >> file_to_get
aws s3 ls s3://seqwell-fastq/$1/ | grep -e csv | awk '{$1=$1}1' OFS="," | cut -f 4 -d "," >> file_to_get


while read line; do
aws s3 cp s3://seqwell-fastq/$1/$line demux_report
done < file_to_get
