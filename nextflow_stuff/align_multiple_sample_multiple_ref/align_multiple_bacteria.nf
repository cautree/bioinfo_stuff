params.run = "20220503_Element"
params.plate = "20220503_Element_FASTQ"
params.dev = true
params.number_of_inputs = 4
params.downsample = 1000

(refs, refs_view) = Channel.fromPath("s3://seqwell-ref/*")
              .map{ item -> tuple(item.baseName.tokenize('.')[0], item) }
              .groupTuple()
              .into(2)
              
//refs_view.view()

(fq, fq_view) = Channel
     .fromFilePairs("s3://seqwell-projects/" + params.run + "/{" + params.plate + "}/*_R{1,2}.fastq.gz", flat: true, checkIfExists: true)
     .take( params.dev ? params.number_of_inputs : -1 )
     .into(2)
     
//fq_view.view()
     
// downsample fastq
process downsample {

     input:
     tuple val(pair_id), path(read1), path(read2) from fq

     output:
     tuple val(pair_id), path('*_R1_001.fastq.gz'), path('*_R2_001.fastq.gz') into sample_fq

     """
     if [ $params.downsample -gt 0 ]; then
     seqtk sample -s 14 ${read1} $params.downsample | gzip > ${pair_id}.${params.downsample}_R1_001.fastq.gz
     seqtk sample -s 14 ${read2} $params.downsample | gzip > ${pair_id}.${params.downsample}_R2_001.fastq.gz
     else
     ln -s ${read1} ${pair_id}_full_R1_001.fastq.gz
     ln -s ${read2} ${pair_id}_full_R2_001.fastq.gz
     fi
     """
}

//220503-PB048-A04-Clostridioides_difficile
(id_sample_ch, id_sample_view) = sample_fq.map{ item -> tuple(item[0].tokenize('-')[3].replace('Rsphaeroides_5plasmid', 'Rhodobacter_sphaeroides'),                                                                          item[0], 
                                                              item[1], 
                                                              item[2]) }.into(2)

//id_sample_view.view()

//Items[0][0]: the ref name
//Items[1][1]: the sample name
//Items[1][2]: fq R1 sequence
//Items[1][3]: fq R2 sequence
//Items[0][1]: all reference files, including bwa index

(ref_fq_ch, ref_fq_view) = refs.cross(id_sample_ch)
                          .map{item -> tuple(item[0][0], item[1][1], item[1][2], item[1][3], item[0][1])}
                          .into(2)

ref_fq_view.view()

// bwa align fastq to reference
process bwa {

     input:
     // also verifies that maps selected files as above
     tuple val(ref_id), val(pair_id), path(read1), path(read2), path(ref) from ref_fq_ch

     output:
     tuple val(pair_id), path('*.bam'), path(ref) into bam_ch

     """
     bwa mem -t $task.cpus ${ref[1]} $read1 $read2 | samtools view -bh -F2048 - | samtools sort > ${pair_id}.bam
     """
}
