params.ref = "pUC19"
refs = Channel.fromPath("s3://seqwell-ref/" + params.ref + ".fa*")
              .collect()

params.downsample = 0
params.wgs = false
params.crosstalk = false

params.dev = false
params.number_of_inputs = 4

if(params.dev) { 
   path_s3 = "seqwell-dev/analysis"
} else { 
   path_s3 = "seqwell-analysis"
}

// notice how this fromFilePairs and splitFastq connected together if split like this, it does not work
// fq = Channel
 //    .fromFilePairs('*{1,2}_001.fastq.gz', compress: true, flat: true, checkIfExists: true)
 //fq2 =fq
//      .splitFastq(by: 500, pe: true, file: true)
fq = Channel
     .fromFilePairs('*{1,2}_001.fastq.gz', compress: true, flat: true, checkIfExists: true)
     .splitFastq(by: 500, pe: true, file: true)
     .map{ it -> tuple(it[0], it[1].baseName.tokenize(".")[0..1].join("."), it[1], it[2]) }
     
     
// bwa align fastq to reference
process bwa {

  //     publishDir path: 'bam', pattern: '*.bam'
  //   publishDir path: "s3://$path_s3/$params.run/$params.analysis/bam"

     input:
     tuple val(pair_id), val(index_id), path(read1), path(read2) from fq
     tuple path(ref), path(ref1), path(ref2), path(ref3), path(ref4), path(ref5), path(ref6) from refs

     output:
     tuple val(pair_id), path('*.bam') into bam_ch

     """
     bwa mem -t $task.cpus $ref $read1 $read2 | samtools view -bh -F2048 - | samtools sort > ${index_id}.bam
     """
}


(collect_bam_ch, collect_bam_ch_view) = bam_ch.groupTuple().into(2)

collect_bam_ch_view.view()


// merge ALL THE BAMS
process mergeBams {

    // publishDir path: "s3://$path_s3/$params.run/$params.analysis/bam"

     input:
     tuple val(pair_id), path(bams) from collect_bam_ch

     output:
     tuple val(pair_id),  path("*.bam") into merge_bam_ch

     """
     samtools merge -@ 16  ${pair_id}.bam *.bam
     """
}


merge_bam_ch.view()
