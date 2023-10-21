#0.01 is the % of reads to output.

## how to make it work?
# cat example.fastq | paste - - - - | awk 'BEGIN{srand(1 2 3 4)}{if(rand() < 0.1) print $0}' | tr -d '\t'  > out.fq

# you will need to calculate the reads first and feed to shuf -n
cat example.fastq | paste - - - - | shuf -n 3 | tr -d '\t'  > out.fq

seqkit sample -p 0.1 example.fastq
