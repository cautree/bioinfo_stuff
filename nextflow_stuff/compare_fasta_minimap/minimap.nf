params.fa_b = "s3://seqwell-analysis/20230328_MiSeq-Appa/assembly-6PLT/100K-230328-NXTFR_FASTA/100K-230328-NXTFR_*.final.fasta"
//params.fa_b = "s3://seqwell-analysis/20230328_MiSeq-Appa/assembly-raw/230328-NXTFR_FASTA/230328-NXTFR_*.final.fasta"
params.fa_a = "concat_fasta/230328-NXTFR_*.final.fasta"
params.run_2 = "100K-230328-NXTFR"
params.run_1 = "230328-NXTFR"
params.outdir = './results'
params.outfile =  params.run_1 + "_vs_" + params.run_2
params.dev = true
params.run ="20230328_MiSeq-Appa"
params.analysis = "fasta_compare_minimap"
params.number_of_inputs =10



if(params.dev) { 
   path_s3 = "seqwell-dev/analysis"
} else { 
   path_s3 = "seqwell-analysis"
}



process get_minimap_res {
errorStrategy 'ignore'

//publishDir path: "${params.outdir}/blastn_metric", mode: 'copy'

input:
tuple val(pair_id), val(name_fa_1),path(fa_1),  val(name_fa_2), path(fa_2)

output:
path ("*")

"""

minimap2 -x ava-ont ${fa_1} ${fa_2} | cut -f 1-12 | awk 'BEGIN { OFS = "," } ;    {\$1="$name_fa_2";  \$6="$name_fa_1";print}'  > ${pair_id}.overlaps.txt

"""

}


process combine_minimap_metrics {

publishDir path: "s3://$path_s3/${params.run}/${params.analysis}/", pattern: "*.csv"


input:
tuple val(plate_id), path("*.txt")

output:
file ("*" )

"""
  minimap_combine_metrics.py ${params.outfile}
"""
}


workflow {

Channel
      .fromPath( params.fa_a  )
      .map { tuple( it.getBaseName(2).split("_")[1], it.getBaseName(2),  it ) }
      .set {fa_1_file}
        
Channel
      .fromPath( params.fa_b )
      .map { tuple( it.getBaseName(2).split("_")[1], it.getBaseName(2), it ) }
      .set {fa_2_file}
      
//fa_1_file.view()
//fa_2_file.view()        
    combined_ch = fa_1_file.join(fa_2_file)
    
    res_ch = get_minimap_res(combined_ch)
    
    all_res_ch = res_ch
            .collect()
            .map{ it -> tuple( params.outfile, it)}
  
    combine_minimap_metrics(all_res_ch)     
      
}



