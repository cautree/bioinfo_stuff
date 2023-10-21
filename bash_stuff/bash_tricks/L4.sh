#turn a fastq to a fasta file:

#bioawk -c fastx '{ print ">"$name ORS $seq }' example.fastq
bioawk -c fastx '{ print ">"$name ORS $seq }' one_example.fastq

awk ' NR%4 == 1 {print ">" substr($0, 2)}  NR%4 == 2 {print}' example.fastq



cat one_example.fastq| paste - - - - | perl -F"\t" -ane 'print ">$F[0]_$F[3]$F[1]";'
less one_example.fastq | paste - - - - | awk 'BEGIN { FS = "\t" };{printf(">%s_%s%s",$1,$4,$2);}' 


## not usre why it does not work
##cat one_example.fastq | sed -n '1~4s/^@/>/p;2~4p'
