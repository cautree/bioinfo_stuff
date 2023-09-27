## on mac has to do this way, otherwise zcat: can't stat: 
zcat < foo.txt.gz 


## turn multi line fasta to oneline
seqtk seq multi-line.fasta > single-line.fasta
## use this to check 
seqtk seq celegans_chr1.fa | head -c 170


## Split a multi-FASTA file into individual FASTA files by awk
awk '/^>/{s=++d".fa"} {print > s}' meta_data/ref.fa

## Split a multi-FASTA file [2 line format] into individual FASTA files by awk
cat meta_data/ref.fa | split -l 2 - ref/seq_


## number of reads in fastq
cat file.fq | echo $((`wc -l`/4))
zcat file.fastq.gz | paste - - - - | wc -l 