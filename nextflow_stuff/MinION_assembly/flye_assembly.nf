#!/home/ec2-user/nextflow/nextflow

params.dev = true
params.number_of_inputs = 12

params.kmers="27,47,63,77,89,99,107,115,121,127"
//params.plates="Addgene_BlueFlame"

//work_dir = file(workflow.workDir).toString()
//params.run = work_dir.split('/')[-3]
params.run = "20230726_MinION"
params.date = "230726"
params.genome_size = "8k"
//params.analysis = work_dir.split('/')[-2]

//assert work_dir.split('/')[-1] == "work"

params.downsample=1000
params.downsample_of_flye = 500

params.analysis = "test_assembly_flye"

if(params.dev) { 
   path_s3 = "seqwell-dev/analysis"
} else { 
   path_s3 = "seqwell-analysis"
}

(fq_ch_1, fq_ch_2) = Channel
     .fromPath("fastq/"+ params.date + "*.fastq.gz", checkIfExists: true)
     .map{ it -> tuple(it.baseName.tokenize(".")[0], it.baseName.tokenize(".")[0].tokenize("_")[0], it)}
     .take( params.dev ? params.number_of_inputs : -1 )
     .into(2)


// downsample fastq
process downsample_flye {

     input:
     tuple val(pair_id), val(plate_id), path(read1) from fq_ch_1

     output:
     tuple val(pair_id), val(plate_id), path('*_R1_flye_001.fastq.gz') into sample_fq_flye
     

     """
     if [ $params.downsample_of_flye -gt 0 ]; then
     seqtk sample -s 14 ${read1} $params.downsample_of_flye | gzip > ${pair_id}.${params.downsample_of_flye}_R1_flye_001.fastq.gz
    
    
     else
     ln -s ${read1} ${pair_id}_full_R1_flye_001.fastq.gz
    
     fi
     """
}


process downsample {

     input:
     tuple val(pair_id), val(plate_id), path(read1) from fq_ch_2

     output:
     tuple val(pair_id), val(plate_id), path('*_R1_001.fastq.gz') into sample_fq1
     tuple val(pair_id), val(plate_id), path('*_R1_copy_001.fastq.gz') into sample_fq2


     """
     if [ $params.downsample -gt 0 ]; then
     seqtk sample -s 14 ${read1} $params.downsample | gzip > ${pair_id}.${params.downsample}_R1_001.fastq.gz
     seqtk sample -s 14 ${read1} $params.downsample | gzip > ${pair_id}.${params.downsample}_R1_copy_001.fastq.gz
    
     else
     ln -s ${read1} ${pair_id}_full_R1_001.fastq.gz
     ln -s ${read1} ${pair_id}_full_R1_copy_001.fastq.gz
    
     fi
     """
}





process flye {

errorStrategy 'ignore'

publishDir path: '.', pattern: '*.csv', mode: 'copy'
publishDir path: "s3://$path_s3/${params.run}/${params.analysis}"


input:
tuple val(pair_id), val(plate_id), path(fq) from sample_fq_flye

output:
tuple val(pair_id), val(plate_id), path("*.assembly_graph.gfa"), path("*.assembly.fasta") into circle_out
tuple val(pair_id), val(plate_id), path('*.assembly_info.txt') into circle_csv


"""
mkdir data
flye --nano-raw ${fq} -g ${params.genome_size} --asm-coverage 50 --out-dir data
mv data/assembly_info.txt ${pair_id}.assembly_info.txt 
mv data/assembly.fasta ${pair_id}.assembly.fasta
mv data/assembly_graph.gfa  ${pair_id}.assembly_graph.gfa 
"""

}


align_in = sample_fq1.join(circle_out, by: [0,1])

//align_in.view()

process minimap2 {

    publishDir path: '.', pattern: '*.csv', mode: 'copy'

     input:
     tuple val(pair_id), val(plate_id), path(fq), path(gfa), path(fa) from align_in

     output:
     path "*bam" into bam
     tuple val(pair_id), val(plate_id), path ("*.csv") into metrics

     """
     if [ -s $fa ]; then
     bwa index $fa


     minimap2 \
    -a $fa \
      $fq \
      | samtools view -bh -F2048 - \
      | samtools sort > ${pair_id}.bam

     samtools depth -a ${pair_id}.bam > ${pair_id}.depth.csv
     samtools view -c ${pair_id}.bam >${pair_id}.count.csv
     
     else
     touch ${pair_id}.depth.csv
     touch ${pair_id}.count.csv
     touch ${pair_id}.bam
     fi
     """
}


metrics = metrics.toList().flatten().toList()

summary_ch = metrics.join(circle_csv, by:[0,1])
             .map{it -> tuple(it[1],tuple(it[2] , it[3] , it[4]))}
             .map{ it -> tuple(it[0], it[1].flatten() )}
              

process summarize {
	
        publishDir path: '.', pattern: '*.csv', mode: 'copy'
        publishDir path: "${plate_id}_FIGS", pattern: '*.png', mode: 'copy'

        publishDir path: "s3://$path_s3/${params.run}/${params.analysis}/", pattern: "*.csv"
    	publishDir path: "s3://$path_s3/${params.run}/${params.analysis}/${plate_id}_FIGS", pattern: "*.png"

	input: 
	tuple val(plate_id), path(metrics) from summary_ch

        output:
        path("*") into summary_output
//        path("*png") into coverage_figures

	"""
	SummarizeAssembly.py $plate_id 
	"""

}
