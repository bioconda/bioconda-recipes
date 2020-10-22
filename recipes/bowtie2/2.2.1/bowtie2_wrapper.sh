#!/bin/bash

usage() {
      echo ""
      echo "Usage : sh $0 -x <reference_index> -i Input_folder {-1 <left_reads> -2 <right_reads> | -U <single_reads>} -S <output_sam>"
      echo ""

cat <<'EOF'
  -x reference index	

  -i </path/to/input folder>

  -1 </path/to/reads_1>

  -2 </path/to/reads_2>

  -U </path/to/single_reads>

  -S </path/to/sam output>

EOF
    exit 0
}

while getopts ":hx:i:1:2:U:S:" opt; do
  case $opt in
    x)
    ref_index=$OPTARG # Reference genome index
     ;;
    i)
    input_folder=$OPTARG # Input folder
     ;;
    1)
    left_reads=$OPTARG # Left reads
     ;;
    2)
    right_reads=$OPTARG # Right reads
     ;;
    U)
    single_reads=$OPTARG # single end reads
     ;;
    S)
    sam_out=$OPTARG # Samoutput file
     ;;
    h)
    usage
     exit 1
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

export BOWTIE2_INDEXES=$input_folder

if [ ! -z $left_reads ] && [ ! -z $right_reads ]; 
then
    bowtie2 -x $ref_index -1 $left_reads -2 $right_reads -S $sam_out

elif [ ! -z $single_reads ]
then
    bowtie2 -x $ref_index -U $single_reads -S $sam_out

else
   echo "You need to specify either two paired end reads or one single end reads for bowtie2 to run"
fi
