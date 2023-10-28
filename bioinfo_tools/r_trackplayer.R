library(rtracklayer)
gtf.file = "sample.GTF"
gtf.gr = rtracklayer::import(gtf.file) # creates a GRanges object
gtf.df = as.data.frame(gtf.gr)
genes = unique(gtf.df[ ,c("gene_id","gene_name")])
library(data.table)
fwrite(genes, file="gene_ID.gene_name.txt", sep="\t")