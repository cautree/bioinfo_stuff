#!/usr/local/bin/nextflow

params.plate = "plate*"

//work
Channel
    .fromPath("data/{" + params.plate + "/}file_{1,2,3,4}.fq")
    .view()
    
    
// Launching `test1.nf` [silly_dijkstra] DSL2 - revision: adb573777d
//Users/yanyan/Documents/test_software/test_bedtools/data/plate2/file_1.fq
//Users/yanyan/Documents/test_software/test_bedtools/data/plate2/file_4.fq
//Users/yanyan/Documents/test_software/test_bedtools/data/plate2/file_3.fq
//Users/yanyan/Documents/test_software/test_bedtools/data/plate2/file_2.fq
//Users/yanyan/Documents/test_software/test_bedtools/data/plate1/file_1.fq
//Users/yanyan/Documents/test_software/test_bedtools/data/plate1/file_4.fq
//Users/yanyan/Documents/test_software/test_bedtools/data/plate1/file_3.fq
//Users/yanyan/Documents/test_software/test_bedtools/data/plate1/file_2.fq   

//work
Channel
    .fromPath("data/" + params.plate + "/file_{1,2,3,4}.fq")
    .view()
    