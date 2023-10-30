echo 'transcript_id "ENSMUST"; gene_name "A" ' > greedy.txt

sed -E 's/transcript_id "(.*)".*/\1/' greedy.txt

sed -E 's/transcript_id "([^"]+)".*/\1/' greedy.txt


bam="231013_153_E05.md.bam"
pair_id=$(basename $bam)
samtools depth -a $bam | tr "\t" "," > ${pair_id}.depth.csv
printf ${pair_id}"\t" > ${pair_id}.zero.txt
cat ${pair_id}.depth.csv | tr "," "\t" | awk '$3==0' | wc -l >> ${pair_id}.zero.txt


bedtools bamtobed -i 231013_153_E05.md.bam > 231013_153_E05.bed
awk -F '\t' '{print NF; exit}'  231013_153_E05.bed  #6
awk -F '\t' 'END {print NR}'  231013_153_E05.bed    #28195
cat 231013_153_E05.bed | wc -l                      #28195


grep "amplicon_0[12]" 231013_153_E05.bed | tail -6
grep -E "amplicon_01|amplicon_02" 231013_153_E05.bed | tail -6

cat sample.GTF | head -2
cat sample.GTF | cut -f9 | cut -d";" -f1 | cut -d" " -f2 | tr -d '"' | sort | uniq 



cat 231013_153_E05.bed | head

awk  '{print $2 "\t" $3}' 231013_153_E05.bed | head -3
awk -v OFS='\t'  '{print $2 , $3}' 231013_153_E05.bed | head -3  # the , is needed in {}›

awk '$1~/amplicon_05/ && $3-$2 > 72' 231013_153_E05.bed | wc -l #14409
awk '$1~/amplicon_05/ && $3-$2 > 74' 231013_153_E05.bed | wc -l #13120

awk '$1~/amplicon_01|amplicon_02/ { print $0 "\t" $3-$2 }' 231013_153_E05.bed > 1.bed
head 1.bed 


## get the mean length
awk 'BEGIN {s=0}; { s +=($3-$2)}; END { print "mean:" s/NR }' 1.bed

awk 'BEGIN  {s=0}; { s +=($3-$2)}; END { print "mean:" s/NR }' 1.bed

cat 1.bed | wc -l
awk '$1 ~ /amplicon_01/ {print}'  1.bed | wc -l
awk '/amplicon_01/ {print}'  1.bed | wc -l

awk '/amplicon_01/ {print $2,"\t", $3}'  1.bed | head -6
awk '/amplicon_01/ {print $2 "\t" $3}'  1.bed | head -6




## associative array awk
cat sample.GTF | head -2
awk '/chr1/{feature[$2]+=1}; END { for (k in feature) print k "\t" feature[k]} ' sample.GTF | sort -k2nr
awk '/miRNA/{feature[$2]+=1}; END { for (k in feature) print k "\t" feature[k]} ' sample.GTF | sort -k2nr


aws s3 ls s3://seqwell-ont/20${date}/fastq_pass/barcode${barcode}/
https://www.biostars.org/p/72177/
#genome    0    26849578    100286070 0.26773
#genome    1    30938928    100286070     0.308507
#genome    2    21764479    100286070    0.217024
#genome    3    11775917    100286070    0.117423
#genome    4    5346208    100286070    0.0533096
#genome    5    2135366    100286070    0.0212927
#genome    6    785983    100286070    0.00783741
#genome    7    281282    100286070    0.0028048
#genome    8    106971    100286070    0.00106666
#genome    9    47419    100286070    0.000472837
#genome    10    27403    100286070    0.000273248
bam=231013_153_E05.md.bam
fa=lambda_amplicons_24.fa
genomeCoverageBed -ibam $bam -g $fa -pc > coverage.txt
cat coverage.txt | head -6

awk '$2==0 {print}' coverage.txt 


## sampling 10%
samtools view -s 0.1 -b m84063_230721_173251_s1.hifi_reads.bc1002.bam -h > m84063_230721_173251_s1.hifi_reads.bc1002_10p.bam





