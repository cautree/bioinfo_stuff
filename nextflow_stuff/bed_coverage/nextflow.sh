run=20230918_MiSeq-Appa
plate=Staphylococcus_epidermidis,Pseudomonas_aeruginosa,Bacillus_subtilis


nextflow run \
bedcoverage.nf \
--plate $plate \
-bg -resume