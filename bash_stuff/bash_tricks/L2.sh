#Bioinformatics one-liner Day 2 Reverse complement a sequence:

echo 'ATTGCTATGCTNNNT' | rev | tr 'ACTG' 'TGAC'

#ANNNAGCATAGCAAT

#rev: reverse the sequence 
#tr: translate the ACTG to its complement TGAC