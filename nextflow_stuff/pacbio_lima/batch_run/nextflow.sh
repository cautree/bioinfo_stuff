#!/bin/bash
samples=*.bam

nextflow run lima.nf \
-c ./nextflow.config \
-work-dir s3://seqwell-dev/analysis/pacbio/lima_test/ \
--samples $samples \
-bg -resume