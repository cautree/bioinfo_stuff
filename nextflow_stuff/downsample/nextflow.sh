#!/bin/bash

run=20230327_MiSeq-Yoda
plates=230327-EPQR_FASTQ
size=500K
downsize=0.0750774
dev=false

nextflow run \
downsample.nf \
 -work-dir . \
 --plates ${plates} \
 --run ${run} \
 --size ${size} \
 --downsize ${downsize} \
 --dev ${dev} \
 -bg -resume
 