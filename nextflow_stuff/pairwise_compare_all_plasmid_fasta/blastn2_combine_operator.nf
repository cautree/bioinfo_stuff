

params.fa_a = "./fasta/*"
params.outfile = "fa_fb_combined"
params.fa_b = "./fasta_b/*"
params.outdir = "results"



process get_blast_res {

publishDir path: "${params.outdir}/${params.outfile}.blastn_metric", mode: 'copy'

input:
tuple path(fa_1),  val(pair_id_1), path(fa_2),  val(pair_id_2)


output:
path ("*.txt")

"""

blastn \
       -num_threads $task.cpus \
       -query ${fa_1} \
       -subject ${fa_2} \
       -outfmt 6 \
       -num_alignments 1 \
       -out ${pair_id_1}_${pair_id_2}.txt

"""


}



process combine_blast_metrics {

publishDir path: "${params.outdir}", mode: 'copy'

input:
tuple val(plate_id), path(blast_res)

output:
file ("*" )

"""
  combine_metrics.py ${params.outfile}
"""

}




workflow {

Channel
      .fromPath( params.fa_a )
      .set {fa_1_file}
        
Channel
      .fromPath( params.fa_b )
      .set {fa_2_file}

fa_1_file
      .combine(fa_2_file)
      .map { tuple( it[0], it[0].baseName.tokenize('.')[0], it[1], it[1].baseName.tokenize('.')[0] ) }
      .set { fa_1_fa_2}
      
    
    res_ch = get_blast_res(fa_1_fa_2)
    
    all_res_ch = res_ch
            .collect()
            .map{ it -> tuple( params.outfile, it)}
            
    all_res_ch.view()

    combine_blast_metrics(all_res_ch)       
}



