#!/bin/bash
#start from /projects/MEP/GWAS_on_ceramides/scripts.rcuadrat#


if [ "$1" == "-h" ]; then
    echo "Usage: bash $0 [options]"
    echo
    echo "   -f, --file_table           file with phenotypes to run in each line - - only specify it if you want to subselect phenotypes from phenotype table"
    echo "   -i, --input_folder         folder with bgen and sample files"
    echo "   -e, --sample_to_exclude    list of samples to be excluded"
    echo "   -p, --phenotypes           table of phenotypes"
    echo "   -o, --output_folder        folder name for output files"
    echo "   -snp, --snp_rate           -snp-missing-rate for qctool - setting snp missing rate cutoff"
    echo "   -hwe, --hwe_value          -hwe for qctool - setting hardy weinberg equilibrium cutoff"
    echo "   -maf_min, --maf_min        -lowest value on interval for maf (minor allele frequency)  for qctool"
    echo "   -maf_max, --maf_max        -maximum value on  interval for maf"
    echo
  exit 0
fi

if [ "$#" == "0" ]; then                      # If zero arguments were supplied,
  echo "Error: no arguments supplied. For help type $0 -h"
  exit 1                                      # and return an error.
fi

##### OPTIONS ###########
PARAMS=""
while (( "$#" )); do
  case "$1" in
    -f|--file_table) #it will be deprecated and the table will be generated automatically from -p table (phenotypes)
      tab=$2
      shift 2
      ;;
      -i|--input_folder)
      input_folder=$2
      shift 2
      ;;
    -e|--sample_to_exclude)
      exclude=$2
      shift 2
      ;;
     -p|--phenotypes)
      phenotypes_table=$2
      shift 2
      ;;
      -o|--output_folder)
      output_folder=$2
      shift 2
      ;;
      -snp|--snp_rate) # -snp-missing-rate 0.05
      snp_rate=$2
      shift 2
      ;;
      -hwe|--hwe_value) # -hwe 3
      hwe_value=$2
      shift 2
      ;;
      -maf_min|--maf_min) # 0.05
      maf_min=$2
      shift 2
      ;;
      -maf_max|--maf_max) # 0.5
      maf_max=$2
      shift 2
      ;;
    --) # end argument parsing
      shift
      break
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done

#########################

top=$(readlink -f ../)/
current=$(pwd)/
chr=( 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 )
mkdir -p ${top}/${output_folder}
mkdir -p ${top}/${output_folder}/filtered_samples/

for j in ${chr[@]}
do
    echo $j
    echo
    echo


    #### FILTERING STEPS  ######

    #exclude individuals due to SAS-phenotypes#

    #-g is the input genetic data
    #-s is the input  identifiers matching data genetics vs phenotype
    #-excl-samples table with indiduals to be removed
    #-og is output after filtring (genetic data)
    #-log the log of the run
    #qctool_v1.4-linux-x86_64/qctool -g ${input_folder}/output_$j.prefix.bgen \ -s ${input_folder}/output_$j.prefix.samples \ hard coded, make run for all *.bgen / *.samples, instead fixed name
    qctool_v1.4-linux-x86_64/qctool -g ${input_folder}/output_$j.bgen \
    -s ${input_folder}/output_$j.samples \
    -excl-samples $exclude \
    -og ${top}/${output_folder}/filtered_samples/filtered_chr$j.bgen \
    -os ${top}/${output_folder}/filtered_samples/filtered_chr$j.sample \
    -log ${top}/${output_folder}/filtered_samples/filtered_chr$j.log  &

     #gzip -f  ${top}/${output_folder}/filtered_samples/filtered_chr$j.log

done
wait

echo "QC filter excluding individuals DONE"

for j in ${chr[@]}
do
#     #exclude SNPs#

#     # -g  filered genetic data (output of the previous step)
#     # -og output filtered SNPs by parameters (-snp-missing-rate 0.05 -maf 0.05 0.5 -hwe 3)
#     # -log the log of the run
#     # -snp-missing-rate setting snp missing rate cutoff
#     # -maf setting minor alelle frequence cutoff
#     # -hwe setting hardy weinberg equilibrium cutoff

    qctool_v1.4-linux-x86_64/qctool -g ${top}/${output_folder}/filtered_samples/filtered_chr$j.bgen \
    -s ${top}/${output_folder}/filtered_samples/filtered_chr$j.sample \
    -og ${top}/${output_folder}/filtered_samples/snp_qc_chr$j.bgen \
    -os ${top}/${output_folder}/filtered_samples/snp_qc_chr$j.sample \
    -log ${top}/${output_folder}/filtered_samples/snp_qc_chr$j.log \
    -snp-missing-rate $snp_rate \
    -maf ${maf_min} ${maf_max} \
    -hwe $hwe_value &

     #gzip -f ${top}/${output_folder}/filtered_samples/snp_qc_chr$j.log

done
wait
    ## END FILTERING STEPS ######

echo "QC filter excluding SNPs DONE"


#####

# check if phenotype table has same sample order of ./${output_folder}/filtered_samples/snp_qc_chr$j.sample #

#python check_sample_order.py $phenotypes_table ${output_folder}


######


#     ###### STARTING GWAS steps ######
chr=( 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 )
for i in $(cat $tab)

    do
        mkdir -p ${top}/${output_folder}/$i

        for j in ${chr[@]}
        do

            #adjusted association test #

            # -data output of previous step (quality controled SNPS for included observations - after filtering)
            # phenotypes.tab - table with phenotypical traits matching IDs for genetic data
            # -frequentist - specify which Frequentist tests to fit (1=Additive, 2=Dominant, 3=Recessive, 4=General and 5=Heterozygote)
            # -log specify log file name from the run
            # -method method used to fit model, this can be one of "threshold", "expected", "score", "ml", "newml", or "em".
            # -use_raw_phenotypes   Do not normalise continuous phenotypes to have mean 0 and variance 1.
            # -missing_code missing code(s) for covariates and phenotypes. This can be a comma-separated list of string values. Defaults to "NA".
            # -o full output of GWAS test
            #hard coded variables ---- need to fix
            snptest_v2.5.2_linux_x86_64_dynamic/snptest_v2.5.2 \
            -data ${top}/${output_folder}/filtered_samples/snp_qc_chr$j.bgen $phenotypes_table \
            -frequentist 1 \
            -log ${top}/${output_folder}/$i/snptest_chr$j.log \
            -method expected \
            -pheno $i \
            -use_raw_phenotypes \
            -cov_names "age" "gender" \
            -missing_code -999 \
            -o ${top}/${output_folder}/$i/assoc_cov_chr$j.txt &


            #gzip ../${output_folder}/$i/snptest_chr$j.log

        done
        wait

        echo "snptest done"

        cd ${top}/${output_folder}/$i
        echo $i
        echo " run manhattan"



        Rscript ${current}/manhattan.R $output_folder/ $top

        echo "end manhattan"

        # removing GWAS result files from snptest

        #rm -f assoc_cov_chr*

        cd ${current}



done
