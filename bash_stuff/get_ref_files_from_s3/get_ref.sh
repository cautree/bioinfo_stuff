#!/bin/bash
set -e

#awk '{$1=$1}1' is the trick to remove extra space
#https://unix.stackexchange.com/questions/102008/how-do-i-trim-leading-and-trailing-whitespace-from-each-line-of-some-output
aws s3 ls s3://seqwell-ref/ | grep ecoli_REL606 | grep -v _ecoli_ | \
awk '{$1=$1}1' OFS="," | cut -f 4 -d "," > ecoli_ref_file

while read line;
do
  aws s3 cp s3://seqwell-ref/$line  ref/
done <ecoli_ref_file
