#!/bin/bash

## -n is to get rid of extra line after echo
s3_path="seqwell-fastq"
run_name="20231016_MiSeq-Yoda"
plate_name="ASU_Ctrl_FASTQ"
echo -n old_id  > old_name
aws s3 ls s3://${s3_path}/${run_name}/${plate_name}/ | awk '{$1=$1}1' OFS="," | cut -f 4 -d "," >> old_name