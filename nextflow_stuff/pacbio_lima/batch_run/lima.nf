#!/usr/local/bin/nextflow
//batch worked on 20231029
//m84063_230721_173251_s1.hifi_reads.bc1001.bam
// the *p.bam is the sampled one with smaller size for testing
params.samples = "*2p.bam"
//do not use as a channel, otherwise, it stops at the first sample
params.barcodes = "./barcodes.fa"
params.date = "231029"

process lima {

publishDir path: 'lima_out', pattern: 'demux/*', mode: 'copy'
publishDir path: 'lima_out', pattern: 'ubam/*.bam', mode: 'copy' 

input:
tuple val(pair_id), path(bam)
each path (barcode)

output:
path ('demux/*')
path ('ubam/*.bam')


"""
mkdir -p demux
lima -d -j 128 --peek-guess  --ccs --min-length 100 --min-score 26 \
--split-named --log-level INFO \
--log-file demux/${pair_id}.lima.log \
${bam} \
${barcode} \
demux/demux.${pair_id}.bam

mkdir bamfile 
mkdir ubam
cp demux/*.bam bamfile/
ls -1 bamfile > file

while read line; do
name=\$(basename bamfile/\$line .bam)
newname=${params.date}_\$(echo \$name | tr -d '-' | cut -d. -f2- | sed 's/seqwell//g' | tr -d '.')
mv bamfile/\${line} ubam/\${newname}.bam
done < file

rm -rf bamfile 
rm file

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


}
//docker_image: quay.io/biocontainers/lima:2.7.1--h9ee0642_0
//install_on_linux: wget https://anaconda.org/bioconda/lima/2.7.1/download/linux-64/lima-2.7.1-h9ee0642_0.tar.bz2
//aws s3 cp s3://seqwell-projects/20230801_Broad_PacBio/20230801_Broad_PacBio_BAM/ bam  --exclude '*'  --include "*.bam" --recursive
//## sampling bam 10%
//samtools view -s 0.1 -b m84063_230721_173251_s1.hifi_reads.bc1002.bam -h > m84063_230721_173251_s1.hifi_reads.bc1002_10p.bam
