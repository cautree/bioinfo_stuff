
bam_ch = Channel
        .fromPath("bam/*.bam")
        .map{ it -> tuple(it.baseName.tokenize('.')[0..2].join('.'), it)}
      



//split bam to each chrom, as picard collect metrics need large memeory if all in
process split_bam {

publishDir path: 'bam_splitted', pattern: '*.bam', mode : 'copy'

input:
tuple val(sample_id), path(bam)


output:
path("*.bam")

"""
  samtools index $bam
  samtools idxstats $bam | cut -f 1 | grep -v '*' > file
  while read chr; do
   samtools view -bo ${sample_id}.\$chr.bam $bam \$chr
  done < file 
  rm file
"""


}


workflow{

bam_split = split_bam(bam_ch)
bam_split.flatten().view()

}