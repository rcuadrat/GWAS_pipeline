#!/bin/bash
mkdir -p ../gsa_out
cd /projects/MEP/GWAS_on_ceramides/scripts.rcuadrat/gsasnp2 ######### HARD CODED @@@@@
# set pathway_data -p
# set db (hg19 0k, 10k, 20k, exome) -g
# set population -a 
# set network -n 
# set if is snp or gene table -s (0 snp, 1 gene)

#declare -a windows=("db19_0k" "db19_20k")
declare -a windows=("db19_20k")

declare -a paths=("Gene_Ontology" "c2.cp.v5.2.symbols.gmt")


#set number of cores to use
cores=16


for p in "${paths[@]}"; do

    mkdir -p ../../gsa_out/$p

    for window in "${windows[@]}"; do

        for file in $(ls ../../tables_for_enrichment/*.txt); do
            echo $file
            out=${file#../../tables_for_enrichment/}
            ./gsasnp2 -i $file -p data/$p -s 0 -o ../../gsa_out/$p/${out%_table_enrich.txt}_${window}.gsa.out -g data/${window} -a data/EUR_Adjacent_correlation -n data/STRING_NETWORK.txt > ../../gsa_out/$p/${out%_table_enrich.txt}_${window}.log &
             background=( $(jobs -p) )
             if (( ${#background[@]} == cores )); then
                wait 
             fi
            done

    done
done


cd ..
