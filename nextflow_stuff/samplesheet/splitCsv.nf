#!/usr/local/bin/nextflow
nextflow.enable.dsl=2

params.samplesheet = "sample.csv"
Channel
    .fromPath(params.samplesheet)
    .splitCsv(header:true)
    .map {
        sample = it['sample']
        file = it['file']
        tuple(sample, file)
     }
    .groupTuple()
    .map { it -> tuple( it[0], it[1][0], it[1][1])}
    .set { ch_samplesheet }
    
ch_samplesheet.view()


process PRO {
    publishDir path: 'output', pattern: '*.txt', mode: 'copy'
    
    input:
        tuple val(samplename), path(file1), path(file2)

    output:
        path("out.txt")

    shell:

        """
        echo $samplename
        cat ${file1} > "out.txt"
        cat ${file2} >> "out.txt"
        
        """
}

workflow { 

PRO(ch_samplesheet) }