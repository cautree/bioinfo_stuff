params.size = "100K"
params.downsize = "0.01501548"
params.plates="230327-EPQR_FASTQ"
params.run = "20230327_MiSeq-Yoda"



params.dev = true
params.number_of_inputs = 4


if(params.dev) {
   path_s3 = "seqwell-dev/analysis"
} else {
   path_s3 = "seqwell-fastq"
}



fq = Channel
     .fromFilePairs("fastq/" + params.plates + "/*_R{1,2}_001.fastq.gz", flat: true)
     .take( params.dev ? params.number_of_inputs : -1 )



process downsample{

publishDir path: '230327-EPQR-100K_FASTQ_from_nf', pattern: '*.fastq.gz', mode : "copy"
publishDir path: "s3://$path_s3/$params.run/${params.size}_$params.plates", mode : "copy"


input:
tuple val(pair_id), path(read1), path(read2) 

output:
tuple val(pair_id), path('*_R1_001.fastq.gz'), path('*_R2_001.fastq.gz') 


"""
seqtk sample -s 14 $read1 $params.downsize | gzip > 100K-${pair_id}_R1_001.fastq.gz
seqtk sample -s 14 $read2 $params.downsize | gzip > 100K-${pair_id}_R2_001.fastq.gz


"""

}

workflow {

downsample(fq)
}

