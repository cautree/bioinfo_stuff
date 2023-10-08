#!/usr/local/bin/nextflow

params.dev = true
params.number_of_inputs = 4
params.ref = "AP-*"
params.run = "20230926_MinION"
params.analysis = "test_combine"
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


(ref_fq_ch1, ref_fq_ch2, ref_fq_view) = refs.join(id_sample_ch, by:0)
                .map{item -> tuple(item[0], item[2], item[3], item[1])}
                .into(3)

ref_fq_view.view()

process collect_insert_length {

tag "$pair_id"

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