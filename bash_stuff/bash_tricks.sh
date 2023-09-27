## on mac has to do this way, otherwise zcat: can't stat: 
zcat < foo.txt.gz 


## turn multi line fasta to oneline
seqtk seq multi-line.fasta > single-line.fasta
## use this to check 
seqtk seq celegans_chr1.fa | head -c 170