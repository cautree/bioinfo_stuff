#!bin/bash

mkdir -p bamfile 
mkdir -p renamed_bamfile
cp *.bam bamfile/
ls -1 bamfile > file
while read line; do
name=$(basename bamfile/$line .bam)
  
newname=${params.date}_\$(echo \$name | tr -d '-' | cut -d. -f2- | sed 's/seqwell//g' | tr -d '.')

##filter out crosstalk ones
a=$(echo $newname | cut -d_ -f3)
b=$(echo $newname | cut -d_ -f5)

if [ $a == $b ]
then
    mv bamfile/${line} renamed_bamfile/${newname}.bam
fi
 
done < file
mv renamed_bamfile/* .
rm -rf bamfile
rm -rf renamed_bamfile