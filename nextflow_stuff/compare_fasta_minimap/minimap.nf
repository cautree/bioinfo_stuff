
params.outfile = "bota_plasmids_compare_gfa_ref_minimap"

process minimap_gfa_ref {

publishDir path: 'minimap_compare_out', pattern: '*', mode: 'copy'
input:
tuple val(ref_name), val(sample_id), path(ref_fa), path(gfa_fa)

output:
path ("*.txt")




"""

minimap2 -x ava-ont  ${gfa_fa} ${ref_fa}  > ${sample_id}.overlaps.txt

"""
}


process combine_minimap_metrics {

//publishDir path: "s3://$path_s3/${params.run}/${params.analysis}/", pattern: "*.csv"
publishDir path: '.', pattern: '*', mode: 'copy'

input:
tuple val(params.outfile), path("*.txt")

output:
file ("*" )

"""
  minimap_combine_metrics.py ${params.outfile}
"""
}





workflow {

Channel
      .fromPath( "../ref/*fa" , checkIfExists: true )
      .map { tuple( it.baseName.tokenize(".")[0],   it ) }
      .set {ref_file}
        
Channel
      .fromPath( "../assembly/gfa_files/fasta/*.fa" ,  checkIfExists: true )
      .map { tuple( it.baseName.tokenize(".")[0].tokenize("_")[2], it.baseName.tokenize(".")[0] , it ) }
      .set {gfa_file}
      
//ref_file.view()
//gfa_file.view()        
    combined_ch = ref_file
                  .cross(gfa_file)
                  .map { it->  tuple( it[0][0], it[1][1], it[0][1], it[1][2])}
//combined_ch.view()
    
    res_ch = minimap_gfa_ref(combined_ch)
    
    all_res_ch = res_ch
              .collect()
              .map{ it -> tuple( params.outfile, it)}
  
    combine_minimap_metrics(all_res_ch)     
      
}




