REFVCF_chl = Channel.fromPath("../software/GLIMPSE/tutorial/reference_panel/1000GP.chr22.noNA12878.sites.vcf.gz")
REFTSV_chl = Channel.fromPath("../software/GLIMPSE/tutorial/reference_panel/1000GP.chr22.noNA12878.sites.tsv.gz")
REFGEN_chl = Channel.fromPath("../software/GLIMPSE/tutorial/reference_genome/hs38DH.chr22.fa.gz")
REFMAP_chl = Channel.fromPath("../software/GLIMPSE/maps/genetic_maps.b37/chr22.b37.gmap.gz")
REFBCF_chl = Channel.fromPath("../software/GLIMPSE/tutorial/reference_panel/1000GP.chr22.noNA12878.bcf")
REFBCF_csi_chl = Channel.fromPath("../software/GLIMPSE/tutorial/reference_panel/1000GP.chr22.noNA12878.bcf.csi")

work_dir = file(workflow.workDir).toString()

bam_ch_0 = Channel.fromPath("s3://seqwell-projects/20221017_Element/20221017_Element_ALIGN_10M/bam/221017-purePlex24-" + params.sample + ".md.bam")
               .map{ file -> tuple(file.name.substring(0,file.name.length() - 7), file) }



process SORT_INDEX {

publishDir path: "s3://seqwell-dev/analysis/20221017_Element_ALIGN_10M/glimpse/sorted_indexed_bam", mode: "copy"

input:
tuple val(pair_id), path(bam)


output:
path("*_sorted.md.bam"), emit: bam
path("*_sorted.md.bam.bai"), emit: bai

"""
samtools sort $bam > ${pair_id}_sorted.md.bam
samtools index ${pair_id}_sorted.md.bam

"""

}



process MPILEUP {

tag "$pair_id"

publishDir path: "mpileup_1017", mode: "copy"
publishDir path: "s3://seqwell-dev/analysis/20221017_Element_ALIGN_10M/glimpse/mpileup", mode: "copy"

input:
tuple val(pair_id), file(bam), file(bai)

path(REFVCF)
path(REFTSV)
path(REFGEN)

output:
path("*mpileup"), emit: mpileup
path("*mpileup.csi"), emit: mpileup_csi

"""

bcftools mpileup \
 -f $REFGEN -I -E \
 -a 'FORMAT/DP' \
 -T $REFVCF \
 -r chr22 $bam \
 -Ou | bcftools call \
 -Aim -C alleles -T $REFTSV \
 -Oz -o ${pair_id}.mpileup
 
bcftools index -f ${pair_id}.mpileup

"""

}


workflow {


sorted_indexed_bam = SORT_INDEX(bam_ch_0)
bam_ch = sorted_indexed_bam.bam
bai_ch = sorted_indexed_bam.bai

bam_ch = bam_ch
        .map{ file -> tuple(file.name.tokenize('/')[-1].substring(0,file.name.tokenize('/')[-1].length() - 7), file) }
        

bai_ch = bai_ch
       .map{ file -> tuple(file.name.tokenize('/')[-1].substring(0,file.name.tokenize('/')[-1].length() - 11), file) }
       

bam_bai_ch = bam_ch.join(bai_ch,  remainder: true)

mpileup_out = MPILEUP( bam_bai_ch,  REFVCF_chl, REFTSV_chl, REFGEN_chl)


}



