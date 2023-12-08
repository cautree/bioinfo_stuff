#!/bin/bash

set -x
set -o errtrace

PB_list=$1
run_name=$2
date=$(echo $run_name | cut -d_ -f1 | cut -c3- )

echo $PB_list | tr " " "\n" | tr -d "PB_"> a.txt

awk  -v var=$date 'BEGIN{OFS="\t"};{print $0, var"_"$1, "n0"}'  a.txt  > ${run_name}.txt

##run as bash create_demux_txt.sh "PB_003 PB_007" 20231206_MiSeq-Yoda_1906