#!/usr/local/bin/nextflow

params.run = "20230621_MiSeq-Sharkboy"
params.plate = "230621-Tagify_FASTQ"
params.dev = true
params.number_of_inputs = 4

//work
fq = Channel
     .fromFilePairs("s3://seqwell-fastq/" + params.run + "/{" + params.plate + "}/*_R{1,3}_001.fastq.gz", flat: true)
     .take( params.dev ? params.number_of_inputs : -1 )

//work    
fq1 = Channel
     .fromFilePairs("s3://seqwell-fastq/" + params.run + "/" + params.plate + "/*_R{1,3}_001.fastq.gz", flat: true)
     .take( params.dev ? params.number_of_inputs : -1 )

//work
UMI_ch_raw = Channel.fromPath("s3://seqwell-fastq/" + params.run + "/" + params.plate + "/*R2_001.fastq.gz")
                .map{ file -> tuple(file.baseName.substring(0,file.name.length() - 16), file) }
                .take( params.dev ? params.number_of_inputs : -1 )

    
fq.view()
fq1.view()
UMI_ch_raw.view()
