#!/bin/bash



set -ex

pwd
cd $PREFIX
folder=$(pwd)
ls
cd ..
pwd
ls
unknown_folder=$(find $folder -type d -name "addsv.tmp" -print)
cd "${unknown_folder}"
pwd
cd .. # go up to be not within addsv.tmp but within bamsurgeon folder
pwd
python3 -O bin/addsv.py -p 1 -v test_data/test_sv.txt -f test_data/testregion_realign.bam -r test_data/Homo_sapiens_chr22_assembly19.fasta -o test_data/testregion_sv_mut.bam --aligner mem --keepsecondary --seed 1234 --inslib test_data/test_inslib.fa
exit 0
