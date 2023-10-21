

## in mac
#zcat < example.fastq.gz
## on linux
#zcat  example.fastq.gz
zless example.fastq.gz | awk 'NR%4 == 2 {lengths[length($0)]++} END {for (l in lengths) {print l, lengths[l]}}'


echo 'ATTGCTATGCTNNNT' | rev | tr 'ACTG' 'TGAC'