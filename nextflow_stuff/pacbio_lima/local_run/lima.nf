#!/usr/local/bin/nextflow
//worked on 20231029
// can only run local, for some reason batch run keeps have same issue
//m84063_230721_173251_s1.hifi_reads.bc1001.bam
params.samples = "m84063_230721_173251_s1.hifi_reads.bc1001.bam"
//do not use as a channel, otherwise, it stops at the first sample
params.barcodes = "./barcodes.fa"

process lima {

publishDir path: 'nextflow_output', pattern: '*', mode: 'copy'
input:
tuple val(pair_id), path(bam)
path (barcode)

output:
path ('*')

"""
lima -d -j 128 --peek-guess  --ccs --min-length 100 --min-score 26 \
--split-named --log-level INFO \
--log-file ${pair_id}.lima.log \
${bam} \
${barcode} \
demux.${pair_id}.bam
"""
}

workflow{
bam_ch = channel
           .fromPath("bam/" + params.samples ) 
           .map { it -> tuple( it.baseName.tokenize('.')[2], it)}
         
bam_ch.view()

//add the i5 i7 as reverse complement of what nextseq takes          
barcode_fa = file( params.barcodes )

lima( bam_ch, barcode_fa)
}
//docker_image: quay.io/biocontainers/lima:2.7.1--h9ee0642_0
//install_on_linux: wget https://anaconda.org/bioconda/lima/2.7.1/download/linux-64/lima-2.7.1-h9ee0642_0.tar.bz2
//aws s3 cp s3://seqwell-projects/20230801_Broad_PacBio/20230801_Broad_PacBio_BAM/ bam  --exclude '*'  --include "*.bam" --recursive