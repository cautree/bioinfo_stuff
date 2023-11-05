#!/bin/bash

ls -1 | grep fastq.gz > fq_file.txt

while read line ; do 
bash get_fa.sh $line
done < fq_file.txt