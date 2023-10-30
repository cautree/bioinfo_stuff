#!bin/bash


  mkdir -p bamfile 
  mkdir -p renamed_bamfile
  cp *.bam bamfile/
  ls -1 bamfile > file
  while read line; do
  name=$(basename bamfile/$line .bam)
  
  newname=$(echo $name | tr -d '-' | cut -d. -f2- | tr -d 'seqwell' | tr -d '.')
  mv bamfile/${line} renamed_bamfile/${newname}.bam
  
  done < file
  mv renamed_bamfile/* .
  rm -rf bamfile
  rm -rf renamed_bamfile
