#!/bin/bash
te_gff=$(echo ${1})
single_te_bed=$(echo ${2})

awk '($2 == "RepeatMasker"){ sum[$10] += $5-$4+1 } END { for (category in sum) print category, sum[category] }' ${te_gff} > genome_TE_length

awk '{ sum[$16] += $3-$2+1 } END { for (category in sum) print category, sum[category] }' ${single_te_bed} > single_TE_length


script_dir=$(cd $(dirname $0);pwd)
python ${script_dir}/abnormal_ERVs.py

