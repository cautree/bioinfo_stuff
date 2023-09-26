#!/bin/bash

if [ -d demux_report ] ; then
rm -rf demux_report
fi

if [ -f file_to_get ] ; then
rm -r file_to_get
fi


aws s3 ls s3://seqwell-fastq/$1/ \
| grep  'txt\|xlsx\|csv' \
| awk '{$1=$1}1' OFS="," \
| cut -f 4 -d "," > file_to_get



while read line; do
aws s3 cp s3://seqwell-fastq/$1/$line demux_report
done < file_to_get


touch demux_report/*
