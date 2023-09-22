#!/home/ec2-user/nextflow/nextflow

//params.plate = "210616-ecoli-i7LP_FASTQ"
params.outfile = "pac_bio_test_1M"
params.ref = "ecoli_REL606"

work_dir = "work"
params.run = "20230515_Overton_PacBio" 
params.analysis = "pac_bio_test"



refs = Channel.fromPath("ref/*")
              .collect()

// need to be float
//params.downsample = 0
// need to be int
params.downsample_count = 1000000

params.wgs = false
params.crosstalk = false

params.dev = true
params.number_of_inputs = 30

if(params.dev) { 
   path_s3 = "seqwell-dev/analysis"
} else { 
   path_s3 = "seqwell-analysis"
}

bam = Channel
     .fromPath("unaligned_bam/*.bam")
     .map{ item -> tuple(item.baseName.tokenize('.')[0], item) }
     .take( params.dev ? params.number_of_inputs : -1 )

// downsample bam
process downsample {

     input:
     tuple val(pair_id), path(read1) from bam

     output:
     tuple val(pair_id), path('*.bam') into sample_bam

     """
     if [ $params.downsample-count -gt 0 ]; then
     zmwfilter  --downsample-count $params.downsample  --downsample-seed 42 ${read1} ${pair_id}.${params.downsample_count}.bam
    
     else
     ln -s ${read1} ${pair_id}_full.bam
  
     fi
     """
}


// pbmm2 align fastq to reference
process pbmm2_align {

//     publishDir path: 'bam', pattern: '*.bam'
     publishDir path: "s3://$path_s3/$params.run/$params.analysis/bam"

     input:
     tuple val(pair_id), path(read1)  from sample_bam
     tuple path(ref), path(ref1), path(ref2) from refs

     output:
     tuple val(pair_id), path('*.pbmm2_aligned.bam') into bam_ch
     tuple val(pair_id), path('*.pbmm2_aligned.bam') into bam_ch2

     """
    
     pbmm2 align $ref1 $read1 ${pair_id}.pbmm2_aligned.bam
     
     """
}


// picard mark duplicates
process markDuplicates_pbmarkdup {

     //publishDir path: 'bam', pattern: '*.bam', mode: "copy"
     publishDir path: "s3://$path_s3/$params.run/$params.analysis/bam", pattern: '*.bam'
  

     input:
     tuple val(pair_id), path(bam) from bam_ch

     output:
     tuple val(pair_id), path('*.md.bam') into md
     file '*.txt' into md_metrics

     """
     
     pbmarkdup \
              --log-level TRACE \
              -f \
              --ignore-read-names \
              $bam  ${pair_id}.md.bam  \
              &>${pair_id}.md.txt
     
     
     
     """
}

// picard metrics
process PacbioMetrics {

     publishDir path: 'metrics', pattern: '*.txt', mode: "copy"
     publishDir path: "s3://$path_s3/$params.run/$params.analysis/metrics", pattern: '*.txt'
    

     input:
     tuple val(pair_id), path(bam) from md
     

     output:
     file '*.txt' into metrics
   

     """
     samtools flagstat $bam \
     | head -5 \
     | tr " " ","  \
     | tr "+" " " \
     | awk -F',' '{ print \$1}' \
     | paste - - - - - - - -    >  align_prp_1
     
      samtools flagstat $bam \
     | head -5 \
     | tr " " ","  \
     | tr "+" " " \
     | awk -F',' '{ print \$3}' \
     | paste - - - - - - - -    >  align_prp_2
     paste align_prp_1  align_prp_2 > align_prp
     cat align_prp
     
     samtools depth $bam \
     |  awk '{sum+=\$3; sumsq+=\$3*\$3} END { print sum/NR, sqrt(sumsq/NR - (sum/NR)**2)}' > coverage
     
     samtools view $bam \
     | awk '{ \$35=length(\$10); sum+=\$35; sumsq+=\$35*\$35} END { print sum/NR, sqrt(sumsq/NR - (sum/NR)**2)}' > length
     
     
     samtools view  $bam \
     | cut -f 10 \
     | fold -w 1 \
     | awk '(\$1=="G" || \$1=="C") {N++;} END {print (N/(1.0*NR)*100);}' > GC_content
     
     echo ${pair_id} | paste - align_prp coverage length  GC_content > ${pair_id}.txt
     
     """
}

all_metrics = metrics.toList().flatten().toList()

process summarize_pacbio {

     stageInMode 'copy'
     publishDir path: '.', mode: 'copy', overwrite: true
     publishDir path: "s3://$path_s3/$params.run/$params.analysis/"

     input:
     file files from all_metrics

     output:
     path '*.csv' into summary
     
     

     """
    
     combine_metrics.py ${params.outfile}.csv
   
     """
}


