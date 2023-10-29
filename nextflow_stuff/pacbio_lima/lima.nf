#!/usr/local/bin/nextflow

bam_ch = channel
           .fromPath("s3://seqwell-projects/20230801_Broad_PacBio/20230801_Broad_PacBio_BAM/m84063_230721_173251_s1.hifi_reads.bc*.bam")
           //.fromPath("bam/*bam") 
           .map { it -> tuple( it.baseName.tokenize('.')[2], it)}
         
bam_ch.view()

//add the i5 i7 as reverse complement of what nextseq takes          
barcode_ch = channel.fromPath("barcodes.fa")

//m84063_230721_173251_s1.hifi_reads.bc1001.bam

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

lima( bam_ch, barcode_ch)

}


//docker image:
//install on linux:
