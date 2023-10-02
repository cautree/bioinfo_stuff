

params.fa_a = "./fasta/p103854.fa"
params.outfile = params.fa_a.tokenize('/')[-1].tokenize('.')[0]
params.fa_b = "./fasta_b/*"
params.outdir = "results"



process get_blast_res {

publishDir path: "${params.outdir}/${params.outfile}.blastn_metric", mode: 'copy'

input:
path(fa_1)
tuple path(fa_2),  val(pair_id)


output:
path ("copy*.txt")

"""

blastn \
       -num_threads $task.cpus \
       -query ${fa_1} \
       -subject ${fa_2} \
       -outfmt 6 \
       -num_alignments 1 \
       -out ${pair_id}.txt

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

fa_1_file = file(  params.fa_a ) 
        
Channel
      .fromPath( params.fa_b )
      .map { tuple( it, it.baseName.tokenize('.')[0] ) }
      .set {fa_2_file}
    
    res_ch = get_blast_res(fa_1_file, fa_2_file)
    
    all_res_ch = res_ch
            .collect()
            .map{ it -> tuple( params.outfile, it)}
            
    all_res_ch.view()

    combine_blast_metrics(all_res_ch)       
}



