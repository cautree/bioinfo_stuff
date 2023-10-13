#!/bin/bash

set -x;
s3_path=$1
run_name=$2
plate_name=$3


#aws s3 ls s3://seqwell-fastq/20231011_MiSeq-Sharkboy/bota_plasmids_FASTQ/ 
echo -n old_id  > old_name
aws s3 ls s3://${s3_path}/${run_name}/${plate_name}/ | awk '{$1=$1}1' OFS="," | cut -f 4 -d "," >> old_name

set +x;

