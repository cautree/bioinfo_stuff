

params.fa_a = "../EP/*"
params.outfile = "bota_plasmids"
params.fa_b = "../ION/*"
params.outdir = "results"



process get_blast_res {

publishDir path: "${params.outdir}/${params.outfile}.blastn_metric", mode: 'copy'

input:
tuple  val(sample_id),val(ref_name), path(fa_1), path(fa_2)


output:
path ("*.txt")

"""

blastn \
       -num_threads $task.cpus \
       -query ${fa_1} \
       -subject ${fa_2} \
       -outfmt 6 \
       -num_alignments 1 \
       -out ${sample_id}_${ref_name}.txt

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

//01_AP-11878.fasta
Channel
      .fromPath( "../EP/*" , checkIfExists: true )
      .map { tuple( it.baseName.tokenize("_")[0],   it ) }
      .set {ref_file}

//BC27_01_AP-11878.assembly.fasta        
Channel
      .fromPath( "../ION/*" ,  checkIfExists: true )
      .map { tuple( it.baseName.tokenize("_")[1], it.baseName.tokenize("_")[2].tokenize(".")[0], it ) }
      .set {gfa_file}
      
    
    //val(sample_id),val(ref_name), path(fa_1), path(fa_2)
    combined_ch = ref_file
                  .cross(gfa_file)
                  .map { it->  tuple( it[0][0],it[1][1], it[1][2], it[0][1])}
    combined_ch.view()
    
    
    res_ch = get_blast_res(combined_ch)
    
    all_res_ch = res_ch
            .collect()
            .map{ it -> tuple( params.outfile, it)}
            
    all_res_ch.view()

    combine_blast_metrics(all_res_ch)       
}



