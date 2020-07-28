#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)


dir = getwd()
print(dir)
i=gsub(paste(args[2],args[1],sep=""),"",dir) 

print(i)


#merge single chromosomes#
file_list=list.files(pattern="assoc_cov_chr")
mydata <- lapply (file_list, read.table, header=TRUE)
dataset <- do.call(rbind, mydata)
print(head(dataset))
write.table(dataset, file=paste(i, "_whole_genome.txt", sep=""), col.names=T, row.names=F, sep = "\t", quote=F)


# creating a collumn on dataframe for chr number
dataset$chromosome <- dataset$alternate_ids
dataset$chromosome <- gsub(":.*?$","",dataset$chromosome)
dataset$chr=as.numeric(as.character(dataset$chromosome))

head(subset(dataset, select=c(rsid, chr, position, alleleA, missing_data_proportion, frequentist_add_pvalue, frequentist_add_beta_1,frequentist_add_se_1)))


# ajusting by number of tests (number of snps * number of phenotypes - **** number of phenotypes is HARD CODED ****)

# TODO - introduce a way to get the number of phenotypes from the table

alevel=(0.05/(nrow(dataset)*61))



nr_SNP=(nrow(dataset))

# selecting by different significance thresholds 
# TODO - create a list of significance thresholds and create a loop for selecting based on the list or, maybe
# just use the higther pvalue thresholds and submit to VPE, and create tables filtering this afterwards to save time on VPE


dataset1 = subset (dataset, dataset$frequentist_add_pvalue<(1e-05))#/61))
dataset1 = dataset1[order(dataset1$frequentist_add_pvalue),]

# dataset2 = subset (dataset, dataset$frequentist_add_pvalue<(1e-07))#/61))
# dataset2 = dataset2[order(dataset2$frequentist_add_pvalue),]

# dataset3 = subset (dataset, dataset$frequentist_add_pvalue<(alevel))
# dataset3 = dataset3[order(dataset3$frequentist_add_pvalue),]

# writing output tables for each significance thresholds

write.table(dataset1, file=paste(i, "_suggestive_results.txt", sep=""), col.names=T, row.names=F, sep = "\t", quote=F)
# write.table(dataset2, file=paste(i, "_genomewide_results.txt", sep=""), col.names=T, row.names=F, sep = "\t", quote=F)
# write.table(dataset3, file=paste(i, "_genomewide_results_alevel.txt", sep=""), col.names=T, row.names=F, sep = "\t", quote=F)
write.table(alevel, file=paste(i, "_alevel.txt", sep=""), col.names=T, row.names=F, sep = "\t", quote=F)
write.table(nr_SNP, file=paste(i, "_tested_SNPs.txt", sep=""), col.names=T, row.names=F, sep = "\t", quote=F)

	
#make Manhattan-Plot and QQPlot#
library(qqman)
head(subset(dataset, select=c(rsid, chr, position, frequentist_add_pvalue)))
jpeg(paste(i, "_ManhattanPlot.jpg", sep=""))
manhattan(subset(dataset),  chr = "chr", bp = "position", p = "frequentist_add_pvalue", snp = "rsid", suggestiveline = -log10(1e-05), genomewideline = -log10(1e-07), main=i, cex=0.8)
dev.off()
jpeg(paste(i, "_QQPlot.jpg", sep=""))
qq(dataset$frequentist_add_pvalue)
dev.off()

######################################

#VPE_Input for whole genome

dataset= subset (dataset, select=c("chr","position","alleleA","alleleB")) #chr, pos, allele A, allele B#
dataset$end = dataset$position
dataset$allele = paste(dataset$alleleA,"/",dataset$alleleB,sep="")


# is all + ???
dataset$strand = c("+") 
dataset= subset (dataset, select=c("chr","position","end","allele", "strand"))
write.table(dataset, file=paste(i,"_input_VPE_whole.txt", sep=""), col.names=F, row.names=F, sep = "\t", quote=F)

######################################

#VPE_Input for different alpha_level#

dataset1= subset (dataset1, select=c("chr","position","alleleA","alleleB")) #chr, pos, allele A, allele B#
dataset1$end = dataset1$position
dataset1$allele = paste(dataset1$alleleA,"/",dataset1$alleleB,sep="")


dataset1$strand = c("+") 
dataset1= subset (dataset1, select=c("chr","position","end","allele", "strand"))
write.table(dataset1, file=paste(i,"_input_VPE_suggestive.txt", sep=""), col.names=F, row.names=F, sep = "\t", quote=F)




# dataset2= subset (dataset2, select=c("chr","position","alleleA","alleleB")) #chr, pos, allele A, allele B#
# dataset2$end = dataset2$position
# dataset2$allele = paste(dataset2$alleleA,"/",dataset2$alleleB,sep="")
# dataset2$strand = c("+") 
# dataset2= subset (dataset2, select=c("chr","position","end","allele", "strand"))
# write.table(dataset2, file=paste(i,"_input_VPE_genomewide.txt", sep=""), col.names=F, row.names=F, sep = "\t", quote=F)

# dataset3= subset (dataset3, select=c("chr","position","alleleA","alleleB")) #chr, pos, allele A, allele B#
# dataset3$end = dataset3$position
# dataset3$allele = paste(dataset3$alleleA,"/",dataset3$alleleB,sep="")
# dataset3$strand = c("+") 
# dataset3= subset (dataset3, select=c("chr","position","end","allele", "strand"))
# write.table(dataset3, file=paste(i,"_input_VPE_alevel.txt", sep=""), col.names=F, row.names=F, sep = "\t", quote=F)




