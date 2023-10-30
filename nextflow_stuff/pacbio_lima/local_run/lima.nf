#!/usr/local/bin/nextflow
//batch worked on 20231029
//m84063_230721_173251_s1.hifi_reads.bc1001.bam
// the *p.bam is the sampled one with smaller size for testing
params.samples = "*p.bam"
//do not use as a channel, otherwise, it stops at the first sample
params.barcodes = "./barcodes.fa"
params.date = "231029"

process lima {

publishDir path: 'demux', pattern: '*', mode: 'copy'


input:
tuple val(pair_id), path(bam)
each path (barcode)

output:
path ('*')
path ('*.bam') ,  emit: bam_file

"""
lima -d -j 128 --peek-guess  --ccs --min-length 100 --min-score 26 \
--split-named --log-level INFO \
--log-file ${pair_id}.lima.log \
${bam} \
${barcode} \
demux.${pair_id}.bam
"""
}

process rename_bam{
publishDir path: 'ubam', pattern: '*.bam', mode: 'copy'

input:
tuple val(pair_id), path(bam)
output:
path('*.bam')

"""
mv $bam ${pair_id}.bam

"""


}


workflow{
bam_ch = channel
           .fromPath("bam/" + params.samples ) 
           .map { it -> tuple( it.baseName.tokenize('.')[2], it)}
         
bam_ch.view()

//add the i5 i7 as reverse complement of what nextseq takes          
barcode_fa = file( params.barcodes )

lima_out =lima( bam_ch, barcode_fa)
//lima_out.bam_file.view()

lima_out_flat = lima_out.bam_file.flatten()
//lima_out_flat.view()

//demux.bc1002_10p.seqwell_G01_P5--seqwell_G01_P7.bam
lima_out_flat_renamed = lima_out_flat
                        .map { it -> tuple(it.baseName.tokenize('.')[1..2].join('.').replace('.seqwell','').tokenize('_')[0..2].join('_'), it)}
                        .map { it -> tuple(params.date+ '_' + it[0], it[1])}

//lima_out_flat_renamed.view()

rename_bam (lima_out_flat_renamed)
}
//docker_image: quay.io/biocontainers/lima:2.7.1--h9ee0642_0
//install_on_linux: wget https://anaconda.org/bioconda/lima/2.7.1/download/linux-64/lima-2.7.1-h9ee0642_0.tar.bz2
//aws s3 cp s3://seqwell-projects/20230801_Broad_PacBio/20230801_Broad_PacBio_BAM/ bam  --exclude '*'  --include "*.bam" --recursive
//## sampling bam 10%
//samtools view -s 0.1 -b m84063_230721_173251_s1.hifi_reads.bc1002.bam -h > m84063_230721_173251_s1.hifi_reads.bc1002_10p.bam
