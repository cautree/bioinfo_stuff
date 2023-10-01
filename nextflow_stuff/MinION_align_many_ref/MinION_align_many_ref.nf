#!/usr/local/bin/nextflow

params.dev = true
params.number_of_inputs = 96
params.ref = "AP-*"
params.run = "20230926_MinION"
params.analysis = "test"
params.wgs = true
params.outfile = "20230926_MinION"
params.date="230926"

if(params.dev) { 
   path_s3 = "seqwell-dev/analysis"
} else { 
   path_s3 = "seqwell-analysis"
}



              
(refs, refs_view) = Channel.fromPath("ref/" + params.ref + ".fa*")
              .map{ item -> tuple(item.baseName.tokenize('.')[0], item) }
              .groupTuple( sort: true)
              .into(2)


//refs_view.view()

fq = Channel
     .fromPath("fastq/*.fastq.gz")
   // .fromPath("fastq/"+ params.date + "*.fastq.gz")
     .take( params.dev ? params.number_of_inputs : -1 )
   
     
     
(id_sample_ch, id_sample_view) = fq.map{ item -> tuple(item.baseName.tokenize('_')[2].tokenize(".")[0], item.baseName.tokenize(".")[0], item) }.into(2)

//id_sample_view.view()


(ref_fq_ch1, ref_fq_ch2, ref_fq_view) = refs.cross(id_sample_ch)
                .map{item -> tuple(item[0][0], item[1][1], item[1][2], item[0][1])}
                .into(3)

ref_fq_view.view()


process collect_insert_length {

//tag "$pair_id"

publishDir path: "s3://$path_s3/$params.run/$params.analysis/insert_hist"

input:
tuple val(ref_id), val(pair_id), path(read1), path(ref) from ref_fq_ch1

output:
tuple val(pair_id), path("*.insert_hist.csv") into hist

"""
zcat ${read1} \
 | paste - - - - | cut -f2 \
 | awk '{print length}' \
 | sort | uniq -c \
 | sort -n -k2,2 \
 | tr -s " " \
 | tr " " "," \
 | cut -d, -f2- \
 > ${pair_id}.insert_hist.csv


"""


}



process minimap2{

publishDir path: "s3://$path_s3/$params.run/$params.analysis/bam"
publishDir path: "bam", mode: "copy"

input:
tuple val(ref_id), val(pair_id), path(read), path(ref) from ref_fq_ch2


output:
tuple val(pair_id), path("*.bam"), path(ref) into bam_ch


"""

minimap2 \
 -a ${ref[0]} \
 ${read} \
 | samtools view -bh -F256 -F2048 \
 | samtools sort > ${pair_id}.bam

"""

}


process markDuplicates {

//errorStrategy 'ignore'

publishDir path: "s3://$path_s3/$params.run/$params.analysis/bam", pattern: '*.bam'
publishDir path: "s3://$path_s3/$params.run/$params.analysis/metrics", pattern: '*.txt'

input:
tuple val(pair_id), path(bam), path(ref) from bam_ch

output:
tuple val(pair_id), path('*.md.bam'), path(ref) into md
tuple val(pair_id), path("*.md.bam") into md2
tuple val(pair_id), path("*.txt") into md_metrics

"""

java -jar /picard.jar MarkDuplicates \
I=${bam} \
O=${pair_id}.md.bam \
M=${pair_id}.dup.txt

"""

}


process picardMetrics {

publishDir path: "s3://$path_s3/$params.run/$params.analysis/metrics", pattern: '*.txt'
publishDir path: "s3://$path_s3/$params.run/$params.analysis/figures", pattern: '*.pdf'


input:
     tuple val(pair_id), path(bam), path(ref) from md
     

output:
     file '*.txt' into metrics
     path '*.pdf' into figures
     path '*.csv' into csvs


"""
java -jar /picard.jar CollectMultipleMetrics \
      VALIDATION_STRINGENCY=SILENT \
      I=$bam \
      O=$pair_id \
      R=${ref[0]} \
      PROGRAM=null \
      PROGRAM=CollectAlignmentSummaryMetrics \
      PROGRAM=CollectGcBiasMetrics 

     mv ${pair_id}.alignment_summary_metrics ${pair_id}.align.txt
     mv ${pair_id}.gc_bias.detail_metrics ${pair_id}.GC.txt
     mv ${pair_id}.gc_bias.pdf ${pair_id}.GC.pdf
     mv ${pair_id}.gc_bias.summary_metrics ${pair_id}.GC_sum.txt
     

     cat ${pair_id}.GC.txt | tail -n 104 | head -n 102 | cut -f3,6,7 | sed 's/\t/,/g' > ${pair_id}.GC.csv
     cat ${pair_id}.insert.txt | awk 'NR > 10' | cut -d. -f1 | sed 's/\t/,/g' > ${pair_id}.insert.csv

     if $params.wgs; then
     java -jar /picard.jar CollectWgsMetrics VALIDATION_STRINGENCY=SILENT CAP=1000000 I=$bam COUNT_UNPAIRED=true MINIMUM_BASE_QUALITY=10 READ_LENGTH=5000 O=${pair_id}.wgs.txt R=${ref[0]}
     fi

"""
}



all_metrics = metrics.toList().concat(md_metrics.toList()).toList().flatten().toList()
other_outputs = csvs.toList().flatten().toList()

// summarize 
process summarize {

     stageInMode 'copy'
     publishDir path: '.', mode: 'copy', overwrite: true
     publishDir path: "s3://$path_s3/$params.run/$params.analysis/"

     input:
     file files from all_metrics
     file outputs from other_outputs

     output:
     path '*.xlsx' into summary
     path '*.zip' into zips


     """
     mkdir -p ${params.outfile}_GCbins
     cp *GC.csv ${params.outfile}_GCbins
     zip ${params.outfile}_GCbins.zip ${params.outfile}_GCbins/*


     combine_metrics.py ${params.outfile}.xlsx
     combine_csvs.py ${params.outfile}
     """
}





process counts {

    // publishDir path: 'counts'
     publishDir path: "s3://$path_s3/$params.run/$params.analysis/counts"

     input:
     tuple val(pair_id), path(bam) from md2

     output:
     path '*.idxstats' into counts


     """
     samtools index $bam
     samtools idxstats $bam > ${pair_id}.idxstats
     """
}

all_counts = counts.toList().flatten().toList()
all_hist = hist.toList().flatten().toList()

process summarizeCounts {

     publishDir path: "s3://$path_s3/$params.run/$params.analysis"

     input:
     file files from all_counts

     output:
     path '*.csv' into summary_counts


     """
     summarize_counts.py ${params.outfile}.counts.csv
     """
}



process summarizeInserts {

     publishDir path: "s3://$path_s3/$params.run/$params.analysis"

     input:
     file files from all_hist

     output:
     path '*insert*.csv' 

     """
     insert_hist.py ${params.outfile}
     """
}





