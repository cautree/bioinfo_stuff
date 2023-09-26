params.run = "20220616_NextSeq550_lanes"
params.plate = "220616-UDI-PlexA_FASTQ"
params.dev = true
params.number_of_inputs = 4


//220616-UDI-PlexA_H02_L004 from file 220616-UDI-PlexA_H02_L004_R2_001.fastq.gz become 220616-UDI-PlexA_H02
(fastq_ch1, fastq_ch2) = Channel
                         .fromFilePairs("s3://seqwell-fastq/" + params.run + "/{" + params.plate + "}/" + "*_R{1,2}_001.fastq.gz", flat: true, checkIfExists: true)
                         .map { it -> tuple( it[0].tokenize("_")[0..1].join("_"),  it[1], it[2]) }
                         .take( params.dev ? params.number_of_inputs : -1 )
                         .groupTuple()
                         .into(2)
                         
     
fastq_ch2.view()

process merge_fastq {

publishDir path: 'fastq', pattern: '*.fastq.gz', mode: 'copy'

input:
     tuple val(prefix), path(reads1), path(reads2) from fastq_ch1

output:
     tuple val(prefix), path('*_R1_001.fastq.gz'), path('*_R2_001.fastq.gz') 


"""
     cat ${reads1}   | gzip > ${prefix}._R1_001.fastq.gz
     cat ${reads2}   | gzip > ${prefix}._R2_001.fastq.gz
     
"""

}



