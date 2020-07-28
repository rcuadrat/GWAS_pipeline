#source("http://bioconductor.org/biocLite.R")
#biocLite("biomaRt",lib="~/R/library")

## I had to install manually sudo apt-get install libcurl4-gnutls-dev


library(biomaRt)
ensembl = useEnsembl(biomart="ensembl", dataset="hsapiens_gene_ensembl")

genes <- getBM(attributes=c('ensembl_gene_id','description','ensembl_transcript_id','go_id','name_1006'), filters =
                      'chromosome_name', values ="1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22", mart = ensembl)
write.table(genes,file="biomart.tsv",sep="\t")
