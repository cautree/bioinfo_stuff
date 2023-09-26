REFGEN_chl = Channel.fromPath("../software/GLIMPSE/tutorial/reference_genome/hs38DH.chr22.fa.gz")

REFGEN_fai_chl = Channel.fromPath("../software/GLIMPSE/tutorial/reference_genome/hs38DH.chr22.fa.gz.fai")
REFGEN_sa_chl = Channel.fromPath("../software/GLIMPSE/tutorial/reference_genome/hs38DH.chr22.fa.gz.sa")
REFGEN_gzi_chl = Channel.fromPath("../software/GLIMPSE/tutorial/reference_genome/hs38DH.chr22.fa.gz.gzi")
REFGEN_dict_chl = Channel.fromPath("../software/GLIMPSE/tutorial/reference_genome/hs38DH.chr22.dict")

truth_vcf_chl = Channel.fromPath("../reference/NA12878/HG001_GRCh38_1_22_v4.2.1_benchmark_chr22.vcf.gz")
truth_tbi_chl = Channel.fromPath("../reference/NA12878/HG001_GRCh38_1_22_v4.2.1_benchmark_chr22.vcf.gz.tbi")

//truth_vcf_chl = Channel.fromPath("../reference/Chinese_trio/NA24694_father/HG006_GRCh38_1_22_v4.2.1_benchmark_chr22.vcf.gz")
//truth_tbi_chl = Channel.fromPath("../reference/Chinese_trio/NA24694_father/HG006_GRCh38_1_22_v4.2.1_benchmark_chr22.vcf.gz.tbi")

//truth_vcf_chl = Channel.fromPath("../reference/Chinese_trio/NA24695_mother/HG007_GRCh38_1_22_v4.2.1_benchmark_chr22.vcf.gz")
//truth_tbi_chl = Channel.fromPath("../reference/Chinese_trio/NA24695_mother/HG007_GRCh38_1_22_v4.2.1_benchmark_chr22.vcf.gz.tbi")

//truth_vcf_chl = Channel.fromPath("../reference/Chinese_trio/NA24631_son/HG005_GRCh38_1_22_v4.2.1_benchmark_chr22.vcf.gz")
//truth_tbi_chl = Channel.fromPath("../reference/Chinese_trio/NA24631_son/HG005_GRCh38_1_22_v4.2.1_benchmark_chr22.vcf.gz.tbi")

//truth_vcf_chl = Channel.fromPath("../reference/HG002_GRCh38_1_22_v4.2.1_benchmark_chr22.vcf.gz")
//truth_tbi_chl = Channel.fromPath("../reference/HG002_GRCh38_1_22_v4.2.1_benchmark_chr22.vcf.gz.tbi")


truth_vcf_chl = truth_vcf_chl
              .map{ file -> tuple(file.name.substring(0,file.name.length() - 7) , file)} 

truth_tbi_chl = truth_tbi_chl
              .map{ file -> tuple(file.name.substring(0,file.name.length() - 11) , file)} 
              
truth_vcf_tbi_chl = truth_vcf_chl.join(truth_tbi_chl)


//params.sample = "A10"
//params.sample = "H03"
eval_chl = Channel.fromPath("glimpse_sample_c1/A10_sampled_c1_sorted.vcf.gz")
              .map{ file -> tuple(file.name.substring(0,file.name.length() - 7) , file)} 

csi_chl = Channel.fromPath("glimpse_sample_c1/A10_sampled_c1_sorted.vcf.gz.tbi")
             .map{ file -> tuple(file.name.substring(0,file.name.length() - 11) , file)} 
              
              
//eval_chl = Channel.fromPath("vcf_c1_22/LP-NovaSeq-" + params.sample +  "_NA12878.10M_chr22_c1.vcf.gz" )
//              .map{ file -> tuple(file.name.substring(0,file.name.length() - 7) , file)} 

//csi_chl = Channel.fromPath("vcf_c1_22/LP-NovaSeq-" + params.sample +  "_NA12878.10M_chr22_c1.vcf.gz.tbi" )
//              .map{ file -> tuple(file.name.substring(0,file.name.length() - 11) , file)} 
              
              

              
eval_csi_chl = eval_chl.join(csi_chl)
eval_csi_chl.view()



process CONCORDANCE {

publishDir path: "concordance", mode: "copy"
//publishDir path: "s3://seqwell-dev/analysis/20221017_Element_ALIGN_10M/glimpse/concordance", mode: "copy"

input:
tuple val(pair_id), file(eval), file(csi)

path(REFGEN)
path(REFGEN_fai)
path(REFGEN_sa)
path(REFGEN_gzi)
path(REFGEN_dict)

tuple val(truth_id), file(truth_vcf), file(truth_vcf_tbi)

output:
file("*")


"""

gatk Concordance \
   -R $REFGEN \
   -eval $eval \
   --truth $truth_vcf \
   --summary ${pair_id}_summary.tsv

"""

}


workflow {

CONCORDANCE( eval_csi_chl, REFGEN_chl, REFGEN_fai_chl,REFGEN_sa_chl, REFGEN_gzi_chl, REFGEN_dict_chl, truth_vcf_tbi_chl)


}

