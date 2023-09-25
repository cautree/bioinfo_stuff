#!/bin/bash

if [ -d analysis_report ] ; then
rm -rf analysis_report
fi

if [ -f file_to_get ] ; then
rm -r file_to_get
fi

mkdir analysis_report

aws s3 ls s3://seqwell-analysis/$1/$2/ | grep -e csv | awk '{$1=$1}1' OFS="," | cut -f 4 -d "," > file_to_get
aws s3 ls s3://seqwell-analysis/$1/$2/ | grep -e xlsx | awk '{$1=$1}1' OFS="," | cut -f 4 -d "," >> file_to_get


while read line; do
aws s3 cp s3://seqwell-analysis/$1/$2/$line analysis_report
done < file_to_get

rm file_to_get