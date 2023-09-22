

params.ref_fasta = "./ref/lambda.fa"
params.ref_fasta_index  = "./ref/lambda.fa.fai"
params.amplicon_intervals = "./ref/p2012.interval_list"
params.target_intervals = "./ref/lambda.interval_list"

params.bam_files = "s3://seqwell-analysis/20230322_MiSeq-Yoda/lambda/bam/*.md.bam"
params.outdir = "./nextflow_results"


process get_pcr_metric {

  publishDir path: "${params.outdir}/pcr_metric_mix_amplicon", pattern: '*.csv', mode: "copy"

  
  input:
  tuple val(pair_id), path(bam_file)
  path ref_fasta
  path ref_fasta_index
  path amplicon_intervals
  path target_intervals

  output:
  path("*")

  """
  java -jar /Users/yanyan/Documents/software/picard.jar CollectTargetedPcrMetrics \
       I=$bam_file \
       O=${pair_id}_pcr_metrics.txt \
       R=$ref_fasta \
       AMPLICON_INTERVALS=$amplicon_intervals \
       TARGET_INTERVALS=$target_intervals
       
  sed -n -e 7p -e 8p ${pair_id}_pcr_metrics.txt |  sed 's/\t/,/g'   > ${pair_id}_2000_pcr_metrics.csv
  
 
  """


}


workflow {

ref_fasta = file( params.ref_fasta)
ref_fasta_index = file( params.ref_fasta_index)
amplicon_intervals = file( params.amplicon_intervals)
target_intervals = file( params.target_intervals )
     

bam_files = Channel
     .fromPath( params.bam_files)
     .map{ item -> tuple(item.getBaseName(2), item) }
bam_files.view()    
get_pcr_metric(bam_files, ref_fasta,ref_fasta_index, amplicon_intervals, target_intervals)

}
