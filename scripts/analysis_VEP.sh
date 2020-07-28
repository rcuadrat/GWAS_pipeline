#!/bin/bash

echo $1
out_folder=$2
top=$3
for j in $(cat $1)
     

do
    echo $j
    cd ${top}/${out_folder}/$j 

    for file in *_input_VPE_suggestive.txt

    do

    perl /projects/MEP/GWAS_pipeline/scripts.rcuadrat/ensembl-tools-release-87/scripts/variant_effect_predictor/variant_effect_predictor.pl\
    --cache --pubmed --offline --check_existing --plugin CADD,/projects/MEP/GWAS_pipeline/CADD_1.3/whole_genome_SNVs.tsv.gz,/projects/MEP/GWAS_pipeline/CADD_1.3/InDels.tsv.gz \
    --symbol --sift b --polyphen b --biotype\
    --fields Uploaded_variation,Location,Existing_variation,SYMBOL,Gene,Allele,Consequence,CADD_PHRED,CADD_RAW,SIFT,PolyPhen,Pubmed,Feature,Feature_type,Biotype,Protein_position,Amino_acids,Codons\
    -i $file\
    -o VPE_suggestive_output.txt\
    --force_overwrite
    
    done 

#     for file in *_input_VPE_genomewide.txt

#     do

#     perl /projects/MEP/GWAS_pipeline/scripts.rcuadrat/ensembl-tools-release-87/scripts/variant_effect_predictor/variant_effect_predictor.pl\
#     --cache --pubmed --offline --check_existing --plugin CADD,/projects/MEP/GWAS_pipeline/CADD_1.3/whole_genome_SNVs.tsv.gz,/projects/MEP/GWAS_pipeline/CADD_1.3/InDels.tsv.gz\
#     --symbol --sift b --polyphen b --biotype\
#     --fields Uploaded_variation,Location,Existing_variation,SYMBOL,Gene,Allele,Consequence,CADD_PHRED,CADD_RAW,SIFT,PolyPhen,Pubmed,Feature,Feature_type,Biotype,Protein_position,Amino_acids,Codons\
#     -i $file\
#     -o VPE_genomewide_output.txt\
#     --force_overwrite
#     done 

#     for file in *_input_VPE_alevel.txt

#     do

#     perl /projects/MEP/GWAS_pipeline/scripts.rcuadrat/ensembl-tools-release-87/scripts/variant_effect_predictor/variant_effect_predictor.pl\
#     --cache --pubmed --offline --check_existing --plugin CADD,/projects/MEP/GWAS_pipeline/CADD_1.3/whole_genome_SNVs.tsv.gz,/projects/MEP/GWAS_pipeline/CADD_1.3/InDels.tsv.gz\
#     --symbol --sift b --polyphen b --biotype\
#     --fields Uploaded_variation,Location,Existing_variation,SYMBOL,Gene,Allele,Consequence,CADD_PHRED,CADD_RAW,SIFT,PolyPhen,Pubmed,Feature,Feature_type,Biotype,Protein_position,Amino_acids,Codons\
#     -i $file\
#     -o VPE_alevel_output.txt\
#     --force_overwrite
#     done


done