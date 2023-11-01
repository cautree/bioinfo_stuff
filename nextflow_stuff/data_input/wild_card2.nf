#!/usr/local/bin/nextflow

params.run = "20231031_NextSeq2000"
params.plate = "DF*_SO11974_FASTQ"
params.dev = true
params.number_of_inputs =4
params.plate1 = "DF2605_SO11974_FASTQ"

//work
fq = Channel
     .fromFilePairs("s3://seqwell-fastq/" + params.run + "/{" + params.plate + "}/*_R{1,2}_001.fastq.gz", flat: true)
     .take( params.dev ? params.number_of_inputs : -1 )
//work
fq1 = Channel
     .fromFilePairs("s3://seqwell-fastq/" + params.run + "/" + params.plate + "/*_R{1,2}_001.fastq.gz", flat: true)
     .take( params.dev ? params.number_of_inputs : -1 )
     
//does not work     
fq2 = Channel
     .fromPath("s3://seqwell-fastq/" + params.run + "/{" + params.plate + "}/*_R1_001.fastq.gz")
     .take( params.dev ? params.number_of_inputs : -1 )
//work
fq3 = Channel
     .fromPath("s3://seqwell-fastq/" + params.run + "/" + params.plate1 + "/*_R1_001.fastq.gz")
     .take( params.dev ? params.number_of_inputs : -1 )

fq.view()
fq1.view()
fq2.view()
fq3.view()