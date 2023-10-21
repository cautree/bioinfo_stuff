#Bioinformatics unix one-liner Day 4 turn a fastq to a fasta file:

cat example.fastq| paste - - - - | perl -F"\t" -ane 'print ">$F[0]_$F[3]$F[1]";'

less example.fastq | paste - - - - | awk 'BEGIN { FS = "\t" };{printf(">%s_%s%s",$1,$4,$2);}' > example.fasta

## not usre why it does not work
##cat example.fastq | sed -n '1~4s/^@/>/p;2~4p'
