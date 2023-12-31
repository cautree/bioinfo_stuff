#!/bin/bash

mkdir -p ref

#tail -n +2, start from the second row
tail -n +2 meta_data/plasmid_sequences_ref.tsv  | awk 'BEGIN{OFS="\n"} {print ">"$1, $4}' > meta_data/ref.fa
## for fasta sequence with 2 lines, can do this, https://www.biostars.org/p/105388/#105402
cat meta_data/ref.fa | split -l 2 - ref/seq_

ls ref | grep seq_ > file

## rename each individual file
## cut -c2-, remove ">"
while read line; do
filename=$(head -1 ref/$line | cut -c2- ) 
echo $filename
cat ref/$line > ref/${filename}.fa
done < file

## clean up
rm file
rm ref/seq_??