#!/bin/bash

set -euxo pipefail

prodigal -h
makeblastdb -h
tblastn -h
augustus
which gff2gbSmallDNA.pl
etraining
new_species.pl
optimize_augustus.pl
hmmsearch -h
run_sepp.py -h
metaeuk -h

# Run CI test for archaea genome pipeline
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/091/665/GCF_000091665.1_ASM9166v1/GCF_000091665.1_ASM9166v1_genomic.fna.gz && gunzip GCF_000091665.1_ASM9166v1_genomic.fna.gz
busco -i GCF_000091665.1_ASM9166v1_genomic.fna --out_path tests/accuracy_tests -o archaea_methanococcales -m geno -l methanococcales_odb10 -c 4
summary_file=tests/accuracy_tests/archaea_methanococcales/short_summary.specific.methanococcales_odb10.archaea_methanococcales.txt
stat $summary_file
verify() { if [ "$(grep "Complete BUSCOs" $summary_file | sed 's/.*\t\(.*\)\tComplete BUSCOs.*/\1/')" != "951" ]; then return 1; fi ; }; verify
verify() { if [ "$(grep "Complete and single-copy" $summary_file | sed 's/.*\t\(.*\)\tComplete and single-copy.*/\1/')" != "949" ]; then return 1; fi ; }; verify
verify() { if [ "$(grep "Complete and duplicated" $summary_file | sed 's/.*\t\(.*\)\tComplete and duplicated.*/\1/')" != "2" ]; then return 1; fi ; }; verify
verify() { if [ "$(grep "Fragmented BUSCOs" $summary_file | sed 's/.*\t\(.*\)\tFragmented BUSCOs.*/\1/')" != "4" ]; then return 1; fi ; }; verify
verify() { if [ "$(grep "Missing BUSCOs" $summary_file | sed 's/.*\t\(.*\)\tMissing BUSCOs.*/\1/')" != "3" ]; then return 1; fi ; }; verify
verify() { if [ "$(grep "Total BUSCO groups" $summary_file | sed 's/.*\t\(.*\)\tTotal BUSCO groups.*/\1/')" != "958" ]; then return 1; fi ; }; verify
