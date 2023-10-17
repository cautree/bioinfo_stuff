#!/bin/bash

data_source="ref"
ends=".fa"
folder="ref_fasta"
while read line; do 

base=$(basename $line $ends)
cat ${folder}/$line | grep -v ">"  >  tmp 
cat ${folder}/$line | grep -v ">"  >> tmp 
cat tmp | tr -d "\n" > tmp2
echo  ">"${base}_${data_source} > ${data_source}_doubled/$line
cat tmp2  >> ${data_source}_doubled/$line 
rm tmp tmp2
done < fafile
