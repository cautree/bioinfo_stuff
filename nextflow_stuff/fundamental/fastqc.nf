//process_exercise_input_answer.nf
nextflow.enable.dsl=2
process FASTQC {
   input:
   path reads

   script:
   """
   mkdir fastqc_out
   fastqc -o fastqc_out ${reads}
   ls -1 fastqc_out
   """
}
reads_ch = Channel.fromPath( 'SH-colonyPCR_H02_R1_001.fastq.gz' )
//does not work
//reads_ch = Channel.fromPath( '${projectDir}/SH-colonyPCR_H02_R1_001.fastq.gz' )

workflow {
  FASTQC(reads_ch)
}