#!/bin/bash

mkdir -p ref

cat meta_data/plasmid_sequences_ref.tsv | tail -n +2 | awk 'BEGIN{OFS="\n"} {print ">"$1, $4}' > meta_data/ref.fa
## for fasta sequence with 2 lines, can do this, https://www.biostars.org/p/105388/#105402
cat meta_data/ref.fa | split -l 2 - ref/seq_

ls ref | grep seq_ > file

## rename each individual file
while read line; do
filename=$(cat ref/$line | head -1 |cut -c2- ) 
echo $filename
cat ref/$line > ref/${filename}.fa
done < file

## clean up
rm file
rm ref/seq_??