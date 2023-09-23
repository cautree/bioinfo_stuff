#!/usr/local/bin/nextflow

params.dev = true
params.number_of_inputs = 12
params.ref = "pUC19"
params.run = "20230726_MinION"
params.analysis = "test"
params.wgs = true
params.outfile = "20230726_MinION"
params.date="230726"

if(params.dev) { 
   path_s3 = "seqwell-dev/analysis"
} else { 
   path_s3 = "seqwell-analysis"
}


refs = Channel.fromPath("s3://seqwell-ref/" + params.ref + ".fa*")
              .collect()


(fq1,fq2) = Channel
   //  .fromPath("fastq/*.fastq.gz")
    .fromPath("fastq/"+ params.date + "*.fastq.gz")
     .map{ it -> tuple(it.baseName.tokenize(".")[0], it)}
     .take( params.dev ? params.number_of_inputs : -1 )
     .into(2)


process collect_insert_length {

//tag "$pair_id"

publishDir path: "s3://$path_s3/$params.run/$params.analysis/insert_hist"

input:
tuple val(pair_id), path(read) from fq1

output:
tuple val(pair_id), path("*.insert_hist.csv") into hist

"""
zcat ${read} \
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
tuple val(pair_id), path(read) from fq2
tuple path(ref), path(ref1), path(ref2), path(ref3), path(ref4), path(ref5), path(ref6) from refs

output:
tuple val(pair_id), path("*.bam") into bam_ch


"""

minimap2 \
 -a ${ref} \
 ${read} \
 | samtools view -bh -F256 -F2048 \
 | samtools sort > ${pair_id}.bam

"""

}


process markDuplicates {

publishDir path: "s3://$path_s3/$params.run/$params.analysis/bam", pattern: '*.bam'
publishDir path: "s3://$path_s3/$params.run/$params.analysis/metrics", pattern: '*.txt'

input:
tuple val(pair_id), path(bam) from bam_ch

output:
tuple val(pair_id), path("*.md.bam") into md
tuple val(pair_id), path("*.md.bam") into md2
tuple val(pair_id), path("*.dup.txt")

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
     tuple val(pair_id), path(bam) from md
     tuple path(ref), path(ref1), path(ref2), path(ref3), path(ref4), path(ref5), path(ref6) from refs

output:
     file '*.txt' into metrics
     path '*.pdf' into figures
     path '*.csv' into csvs


"""
java -jar /picard.jar CollectMultipleMetrics \
      VALIDATION_STRINGENCY=SILENT \
      I=$bam \
      O=$pair_id \
      R=$ref \
      PROGRAM=null \
      PROGRAM=CollectAlignmentSummaryMetrics \
      PROGRAM=CollectGcBiasMetrics \
      PROGRAM=CollectInsertSizeMetrics

     mv ${pair_id}.alignment_summary_metrics ${pair_id}.align.txt
     mv ${pair_id}.gc_bias.detail_metrics ${pair_id}.GC.txt
     mv ${pair_id}.gc_bias.pdf ${pair_id}.GC.pdf
     mv ${pair_id}.gc_bias.summary_metrics ${pair_id}.GC_sum.txt
     if [ -f ${pair_id}.insert_size_metrics ]; then
     	mv ${pair_id}.insert_size_metrics ${pair_id}.insert.txt
     	mv ${pair_id}.insert_size_histogram.pdf ${pair_id}.insert.pdf
     else
     	touch ${pair_id}.insert.txt
     	touch ${pair_id}.insert.pdf
     fi

     cat ${pair_id}.GC.txt | tail -n 104 | head -n 102 | cut -f3,6,7 | sed 's/\t/,/g' > ${pair_id}.GC.csv
     cat ${pair_id}.insert.txt | awk 'NR > 10' | cut -d. -f1 | sed 's/\t/,/g' > ${pair_id}.insert.csv

     if $params.wgs; then
     java -jar /picard.jar CollectWgsMetrics VALIDATION_STRINGENCY=SILENT CAP=1000000 I=$bam O=${pair_id}.wgs.txt R=$ref
     fi


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




