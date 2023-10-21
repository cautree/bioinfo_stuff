#Day 3 split a multi-fasta to multiple single fasta file

cat multi_fasta.fa


cat multi_fasta.fa | awk '{
if (substr($0, 1, 1)==">") {filename=(substr($0,2) ".fasta")}
print $0 >> filename
close(filename)
}'

#or use csplit

#csplit -k multi_fasta.fa