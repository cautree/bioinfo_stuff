#!/bin/bash
for val in {1..22}; do
wget -c http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000G_2504_high_coverage/working/20201028_3202_phased/CCDG_14151_B01_GRM_WGS_2020-08-05_chr${val}.filtered.shapeit2-duohmm-phased.vcf.gz{,.tbi}
done