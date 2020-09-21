#!/bin/bash

#GWAS analysis pipeline
#start from here /scripts #


if [ "$1" == "-h" ]; then
    echo "Usage: bash $0 [options]"
    echo
    echo "   -f, --file_table           file with phenotypes to run in each line - only specify it if you want to subselect only some phenotypes from phenotype table, otherwise it will be generate automatically from table of phenotypes"
    echo "   -i, --input_folder         folder with bgen and sample files"
    echo "   -e, --sample_to_exclude    list of samples to be excluded"
    echo "   -p, --phenotypes           table of phenotypes"
    echo "   -o, --output_folder        folder name for output files"
    echo "   -snp, --snp_rate           -snp-missing-rate for qctool - setting snp missing rate cutoff"
    echo "   -hwe, --hwe_value          -hwe for qctool - setting hardy weinberg equilibrium cutoff"
    echo "   -maf_min, --maf_min        -lowest value on interval for maf (minor allele frequency)  for qctool"
    echo "   -maf_max, --maf_max        -maximum value on  interval for maf"
  exit 0
fi

if [ "$#" == "0" ]; then                      # If zero arguments were supplied,
  echo "Error: no arguments supplied. For help type bash $0 -h"
  exit 1                                      # and return an error.
fi


#      include  -maf 0.05 0.5 \ still hard coded


PARAMS=""
while (( "$#" )); do
  #echo $#
  case "$1" in
    -f|--file_table)
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

### treating missing options and defaults ###

if [ -z $tab ]; then
    echo "option -f not defined, using default '../list_of_variables.tsv'"
    tab='../list_of_variables.tsv'
fi

if [ -z $input_folder ]; then
    echo "option -i not defined, using default '../bgen_files/'"
    input_folder='../bgen_files/'
fi

 if [ -z $output_folder ]; then
     echo "option -o not defined, using default 'GWAS_OUT'"
    output_folder="GWAS_OUT"
 fi

if [ -z $exclude ]; then
    echo "option -e not defined, using default '../SAMPLES_TO_EXCLUDE.tab'"
    exclude='../SAMPLES_TO_EXCLUDE.tab'
fi

if [ -z $phenotypes_table ]; then
    echo "option -p not defined, using default '../phenotypes.tab'"
    phenotypes_table='../phenotypes.tab'
fi
if [ -z $snp_rate ]; then
    echo "option -snp not defined, using default 0.05'"
    snp_rate='0.05'
fi

if [ -z $hwe_value ]; then
    echo "option -hwe not defined, using default 3'"
    hwe_value='3'
fi

if [ -z $maf_min ]; then
    echo "option -maf_min not defined, using default 0.05'"
    maf_min='0.05'
fi

if [ -z $maf_max ]; then
    echo "option -maf_max not defined, using default 0.5'"
    maf_max='0.5'
fi

top=$(readlink -f ../)/
current=$(pwd)/

#######################################
# # Generating list of phenotypes

python generate_list_of_variables_from_phenotypes.py $phenotypes_table

# #######################################

echo "Starting filtering, snptest and manhattan"


bash GWAS_first_steps.sh -f $tab -i $input_folder -e $exclude -p $phenotypes_table -o $output_folder -snp $snp_rate -hwe $hwe_value -maf_min $maf_min -maf_max $maf_max #

# ########################################


echo " Finished filtering, snptest and manhattan"


#run VEP on results#

echo " starting VEP "
cd $current

bash analysis_VEP.sh $tab $output_folder $top

########################################

#merge VEP results with SNP-test results#

echo " Finished VEP"

echo " Merging tables VEP and GWAS"



Rscript VEP.R $output_folder $top


# ########################################


echo "Parsing and generating tables for enrichment"

mkdir -p ${top}/tables_for_enrichment
mkdir -p ${top}/mrtables


python annotated_suggestive_results_parser.py $output_folder


# ########################################


# ## running gsa_snp2

bash run_gsa.sh

