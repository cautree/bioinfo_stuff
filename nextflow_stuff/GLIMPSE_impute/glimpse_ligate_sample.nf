
              
params.sample = "B11"

bcfs = Channel.fromPath("glimpse_phase/221017-purePlex24-{" +params.sample + "}_sorted_*_imputed_bcf").collect()
bcfs_index = Channel.fromPath("glimpse_phase/221017-purePlex24-{" +params.sample + "}_sorted_*_imputed_bcf.csi").collect()
  
               

impute_list = Channel.fromPath("bcf_list/" + params.sample)
sample_val = Channel.from( params.sample )


process GLIMPSE_LIGATE {

publishDir path: "glimpse_ligate", mode: "copy"
publishDir path: "s3://seqwell-dev/analysis/20221017_Element_ALIGN_10M/glimpse/ligate", mode: "copy"

input:
val(pair_id)
file(impute_list)
path(bcfs)
path(bcfs_index)


output:
file("*merge.bcf")

"""
GLIMPSE_ligate --input $impute_list --output ${pair_id}_merge.bcf
"""

}



process INDEX_MERGED_BCF {

publishDir path: "glimpse_ligate", mode: "copy"
publishDir path: "s3://seqwell-dev/analysis/20221017_Element_ALIGN_10M/glimpse/ligate", mode: "copy"

input:
file(merge_bcf)

output:
path("*")


"""
bcftools index -f $merge_bcf

"""
}


process GLIMPSE_SAMPLE {

publishDir path: "glimpse_sample", mode: "copy"
publishDir path: "s3://seqwell-dev/analysis/20221017_Element_ALIGN_10M/glimpse/sample", mode: "copy"

input:
val(pair_id)
file(merge_bcf)
file(merge_bcf_index)

output:
file("*bcf")


"""
GLIMPSE_sample --input $merge_bcf --solve --output ${pair_id}_sampled.bcf
"""


}



process INDEX_SAMPLED_BCF {

publishDir path: "glimpse_sample", mode: "copy"
publishDir path: "s3://seqwell-dev/analysis/20221017_Element_ALIGN_10M/glimpse/sample", mode: "copy"

input:
tuple val(pair_id), file(sampled_bcf)

output:
file("*")


"""
bcftools view $sampled_bcf >${pair_id}_sampled.vcf

"""
}



workflow {

ligate = GLIMPSE_LIGATE (sample_val, impute_list, bcfs, bcfs_index)
ligate.view()

ligate_index = INDEX_MERGED_BCF(ligate)

sample = GLIMPSE_SAMPLE(sample_val, ligate,  ligate_index)

sample_chl = sample
        .map{ file -> tuple(file.name.substring(0,file.name.length() - 12) , file)} 

INDEX_SAMPLED_BCF(sample_chl)

}