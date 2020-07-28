#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

print(args)

setwd(paste(args[2],args[1],sep=""))
getwd()
for (dir in list.dirs()[-1]) {

    setwd(dir)
    print(dir)

    x=gsub(paste(args[2],args[1],sep=""),"",dir)
    i=gsub("./","",x)

    print(i)

        #suggestive#

        file1= paste (i,"_suggestive_results.txt",sep="")
        print(file1)
        file2= paste ("VPE_suggestive_output",".txt",sep="")
        print(file2)
        if (file.exists(file2)) {

            snptest=read.table(file1, header=T, as.is=T)

            vep=read.table(file2, header=F, as.is=T)
        names(vep) <- c("Uploaded_variation","Location","Rs-Number","SYMBOL","Gene","Allele_VEP","Consequence","CADD_PHRED","CADD_RAW","SIFT","PolyPhen","Pubmed","Feature","Feature_type","Biotype","Protein_position","Amino_acids","Codons")
        snptest$Location_SNPtest = paste(snptest$chromosome,":",snptest$position,sep="")
        complete <- merge (snptest,vep, by.x="Location_SNPtest", by.y="Location", all.y=T)
        complete1 <- subset (complete, select=c("Uploaded_variation","Location_SNPtest","Rs-Number","info","SYMBOL","Allele_VEP","Consequence","CADD_PHRED","all_total","all_maf","alleleB","frequentist_add_pvalue","frequentist_add_beta_1","frequentist_add_se_1"))

        complete = complete[order(complete$frequentist_add_pvalue),]
        complete1 = complete1[order(complete1$frequentist_add_pvalue),]

        write.table(complete, file=paste("annotated_suggestive_results",i,".txt", sep=""), col.names=T, row.names=F, sep = "\t", quote=F)
        write.table(complete1, file=paste("summary_suggestive_results",i,".txt", sep=""), col.names=T, row.names=F, sep = "\t", quote=F)
        } else {
            print(i)
            print("no suggestive results")
        }
    # generate here a new table from complete1 (for enrichment analysis), removing duplicates and getting only "Rs-Number" and "frequentist_add_pvalue"


    # #genomewide#

# 		file3= paste (i,"_genomewide_results.txt",sep="")
# 		file4= paste ("VPE_genomewide_output",".txt",sep="")

# 		if (file.exists(file4)) {

# 		snptest=read.table(file3, header=T, as.is=T)
# 		snptest$Location_SNPtest = paste(snptest$chromosome,":",snptest$position,sep="")

# 		vep=read.table(file4, header=F, as.is=T)
# 		names(vep) <- c("Uploaded_variation","Location","Rs-Number","SYMBOL","Gene","Allele_VEP","Consequence","CADD_PHRED","CADD_RAW","SIFT","PolyPhen","Pubmed","Feature","Feature_type","Biotype","Protein_position","Amino_acids","Codons")

# 		complete <- merge (snptest,vep, by.x="Location_SNPtest", by.y="Location", all.y=T)
# 		complete1 <- subset (complete, select=c("Uploaded_variation","Location_SNPtest","Rs-Number","info","SYMBOL","Allele_VEP","Consequence","CADD_PHRED","all_total","all_maf","alleleB","frequentist_add_pvalue","frequentist_add_beta_1","frequentist_add_se_1"))

# 		complete = complete[order(complete$frequentist_add_pvalue),]
# 		complete1 = complete1[order(complete1$frequentist_add_pvalue),]


# 		write.table(complete, file=paste("annotated_genomewide_results",i,".txt", sep=""), col.names=T, row.names=F, sep = "\t", quote=F)
# 		write.table(complete1, file=paste("summary_genomewide_results",i,".txt", sep=""), col.names=T, row.names=F, sep = "\t", quote=F)

# 		} else {
# 			print(i)
# 			print("no genomewide results")
# 		}


# 		#alevel#

# 		file5= paste (i,"_genomewide_results_alevel.txt",sep="")
# 		file6= paste ("VPE_alevel_output",".txt",sep="")

# 		if (file.exists(file6)) {


# 		snptest=read.table(file5, header=T, as.is=T)
# 		snptest$Location_SNPtest = paste(snptest$chromosome,":",snptest$position,sep="")

# 		vep=read.table(file6, header=F, as.is=T)
# 		names(vep) <- c("Uploaded_variation","Location","Rs-Number","SYMBOL","Gene","Allele_VEP","Consequence","CADD_PHRED","CADD_RAW","SIFT","PolyPhen","Pubmed","Feature","Feature_type","Biotype","Protein_position","Amino_acids","Codons")

# 		complete <- merge (snptest,vep, by.x="Location_SNPtest", by.y="Location", all.y=T)
# 		complete1 <- subset (complete, select=c("Uploaded_variation","Location_SNPtest","Rs-Number","info","SYMBOL","Allele_VEP","Consequence","CADD_PHRED","all_total","all_maf","alleleB","frequentist_add_pvalue","frequentist_add_beta_1","frequentist_add_se_1"))

# 		complete = complete[order(complete$frequentist_add_pvalue),]
# 		complete1 = complete1[order(complete1$frequentist_add_pvalue),]

# 		write.table(complete, file=paste("annotated_alevel_results",i,".txt", sep=""), col.names=T, row.names=F, sep = "\t", quote=F)
# 		write.table(complete1, file=paste("summary_alevel_results",i,".txt", sep=""), col.names=T, row.names=F, sep = "\t", quote=F)

# 		} else {
# 			print(i)
# 			print("no alevel results")
# 		}

    setwd("../")

}

