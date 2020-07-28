#!/usr/bin/env python

import pandas as pd
import os
import sys


path="../"+sys.argv[1]+"/"

print("path:")
print(path)

cols_to_keep=['Rs-Number','alternate_ids','rsid', 'SYMBOL', 'Gene','frequentist_add_pvalue','Feature', 'Feature_type','Consequence','Allele_VEP',
        'all_AA','all_AB', 'all_BB', 'all_NULL', 'all_total','CADD_PHRED', 'CADD_RAW',
       'frequentist_add_beta_1', 'frequentist_add_se_1','all_maf']

#biomart table with annotation of genes (description and GO number/name)
biomart=pd.read_csv("/projects/MEP/GWAS_pipeline/biomart.tsv",sep="\t")
biomart.rename(columns={"ensembl_gene_id":"Gene"},inplace=True)
biomart.rename(columns={"ensembl_transcript_id":"Feature"},inplace=True)
biomart_join=biomart.fillna("-").groupby(["Gene","Feature"]).agg(lambda x: ";".join(x.drop_duplicates())).reset_index()


writer = pd.ExcelWriter(path+'/annotated_suggestive_results.xlsx')

var=[]

#all_df=pd.DataFrame()
#all_df_full=pd.DataFrame()
for foldername in os.listdir(path):
    if foldername != "filtered_samples":
        if os.path.isfile(path+foldername+"/"+"annotated_suggestive_results"+foldername+".txt")==True:
            df=pd.read_csv(path+foldername+"/"+"annotated_suggestive_results"+foldername+".txt",sep="\t")
            df_short=df[cols_to_keep]

            ####################################################################
            df_short=pd.merge(df_short,biomart_join,on=["Gene","Feature"],how="left")
            df_short[['description', 'go_id', 'name_1006']]=df_short[['description', 'go_id', 'name_1006']].astype(str)

            #
            df_join=df_short.groupby("Rs-Number")[["Feature","Feature_type","SYMBOL","Gene","Consequence","description","go_id","name_1006"]].aggregate(lambda x: ";".join(x.drop_duplicates()))
            df_join.reset_index(inplace=True)
            df_short=pd.merge(df_short.drop(["Feature","Feature_type","SYMBOL","Gene","Consequence","description","go_id","name_1006"],axis=1),df_join,on="Rs-Number").drop_duplicates()
        #


        ##
            df_short=df_short[['Rs-Number', 'rsid','alternate_ids','SYMBOL', 'Gene', 'frequentist_add_pvalue',"description","go_id","name_1006", 'Feature_type','Feature','Consequence','all_AA',
             'all_AB', 'all_BB', 'all_NULL', 'all_total','CADD_PHRED', 'CADD_RAW', 'frequentist_add_beta_1','frequentist_add_se_1','all_maf']]
            df_short.to_excel(writer, sheet_name=foldername,index=None)

            #################################################################




            df_short["Variable"]=str(foldername)
            var.append(foldername)


            # generating tables for MRbase 
            df_short["effect_allele"]=df_short["alternate_ids"].str.split("_",expand=True)[2]
            df_short["other_allele"]=df_short["alternate_ids"].str.split("_",expand=True)[1]
            df_short["eaf"]=(df_short["all_AB"]+(df_short["all_BB"]*2))/(df_short["all_total"]*2)
            a=df_short[["Variable","Rs-Number","frequentist_add_beta_1","frequentist_add_se_1","effect_allele","other_allele","eaf","frequentist_add_pvalue","Gene","all_total"]]
            a["units"]="NA"
            a.columns=["Phenotype", "SNP", "beta", "se", "effect_allele", "other_allele","eaf","pval","gene","samplesize","units"]
            a=a[["Phenotype","SNP", "beta", "se", "effect_allele", "other_allele","eaf","pval","units","gene","samplesize"]]
            a.to_csv("../mrtables/" + str(foldername) +"_file_for_mrbase.tsv",sep="\t",index=None)


            #all_df=pd.concat([all_df,df_])
            #all_df_full=pd.concat([all_df_full,df_short])
#         except:
#             print("No suggestive results for: ",foldername)
        
writer.save()


#all_df.to_excel("../annotated_suggestive_results_one_sheet.xlsx",index=None)


## anottating with biomart (table generated by biomart_annotation.R script)





#all_df_full_annotated=pd.merge(all_df_full,biomart_join,on=["Gene","Feature"],how="left")


# all_df_full_annotated=all_df_full_annotated[['Variable', 'Rs-Number', 'rsid', 'SYMBOL', 'Gene','description',
#        'frequentist_add_pvalue', 'Feature','go_id', 'name_1006', 'Feature_type', 'Consequence',
#        'Allele_VEP', 'all_AA', 'all_AB', 'all_BB', 'all_NULL', 'all_total',
#        'CADD_PHRED', 'CADD_RAW', 'frequentist_add_beta_1',
#        'frequentist_add_se_1']]


#all_df_full_annotated.to_excel("../annotated_suggestive_results_one_sheet_GO.xlsx",index=None)





#var=list(set(all_df["Variable"]))
for v in var:
    whole_genome=pd.read_table(path+v+"/"+v+"_whole_genome.txt")

    #whole_genome["chromosome"]=whole_genome["alternate_ids"].str.split(":",expand=True)[0]
    #whole_genome=whole_genome[["chromosome","position","position","alleleA","alleleB","frequentist_add_pvalue"]]
    #whole_genome.columns=[0,1,2,3,4,"pvalue"]
    #whole_genome[0]=whole_genome[0].astype(int)
    
    # this will be deprecated with the new bgen files including RS-id 
    #rs_table=pd.merge(whole_genome,snptable,on=[0,1,2,3,4],how="left")
    #rs_table.drop_duplicates([0,1,2,3,4],inplace=True)
    
    whole_genome[["rsid","frequentist_add_pvalue"]].dropna().drop_duplicates().to_csv("../tables_for_enrichment/"+v+"_table_enrich.txt",sep="\t",header=None,index=None)