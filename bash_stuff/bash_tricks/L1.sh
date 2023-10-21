#Day 1 Get the sequence length distribution from a fastq file using awk:

## in mac
#zcat < example.fastq.gz
## on linux
#zcat  example.fastq.gz

zless example.fastq.gz | awk 'NR%4 == 2 {lengths[length($0)]++} END {for (l in lengths) {print l, lengths[l]}}'

#Initiate an awk arrary named lengths, save all the record length to it and increment the frequency by array[]++ A fastq record contains 4 lines. when line number can be divided by 4 and leave 2: NR%4 == 2 to get the sequence line. length($0) gives the length of the full line denoted by $0.
#When the awk finishes reading all lines: END print out the lengths and its frequency