#!/usr/local/bin/nextflow

params.plate = "plate*"
params.plate1 = "plate1"

//not work
Channel
    .fromPath("data/{" + params.plate + "/}file_[1-4].fq")
    .view()

//work
Channel
    .fromPath("data/" + params.plate1 + "/file_[1-4].fq")
    .view()

//work   
Channel
    .fromPath("data/" + params.plate + "/file_[1-4].fq")
    .view()