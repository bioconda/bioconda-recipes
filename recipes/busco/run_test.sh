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

# Run CI test for archaea lineage genome pipeline
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/091/665/GCF_000091665.1_ASM9166v1/GCF_000091665.1_ASM9166v1_genomic.fna.gz && gunzip GCF_000091665.1_ASM9166v1_genomic.fna.gz
busco -i GCF_000091665.1_ASM9166v1_genomic.fna --out_path tests/accuracy_tests -o archaea_methanococcales -m geno -l methanococcales_odb10 -c 12
summary_file=tests/accuracy_tests/archaea_methanococcales/short_summary.specific.methanococcales_odb10.archaea_methanococcales.txt
stat $summary_file
verify() { if [ "$(grep "Complete BUSCOs" $summary_file | sed 's/.*\t\(.*\)\tComplete BUSCOs.*/\1/')" != "951" ]; then return 1; fi ; }; verify
verify() { if [ "$(grep "Complete and single-copy" $summary_file | sed 's/.*\t\(.*\)\tComplete and single-copy.*/\1/')" != "949" ]; then return 1; fi ; }; verify
verify() { if [ "$(grep "Complete and duplicated" $summary_file | sed 's/.*\t\(.*\)\tComplete and duplicated.*/\1/')" != "2" ]; then return 1; fi ; }; verify
verify() { if [ "$(grep "Fragmented BUSCOs" $summary_file | sed 's/.*\t\(.*\)\tFragmented BUSCOs.*/\1/')" != "4" ]; then return 1; fi ; }; verify
verify() { if [ "$(grep "Missing BUSCOs" $summary_file | sed 's/.*\t\(.*\)\tMissing BUSCOs.*/\1/')" != "3" ]; then return 1; fi ; }; verify
verify() { if [ "$(grep "Total BUSCO groups" $summary_file | sed 's/.*\t\(.*\)\tTotal BUSCO groups.*/\1/')" != "958" ]; then return 1; fi ; }; verify

# Run CI test for archaea lineage transcriptome pipeline
busco -i tests/accuracy_tests/archaea_methanococcales/prodigal_output/predicted_genes/predicted.fna --out_path tests/accuracy_tests -o archaea_archaea -m tran -l archaea_odb10 -c 12
summary_file=tests/accuracy_tests/archaea_archaea/short_summary.specific.archaea_odb10.archaea_archaea.txt
stat $summary_file
verify() { if [ "$(grep "Complete BUSCOs" $summary_file | sed 's/.*\t\(.*\)\tComplete BUSCOs.*/\1/')" != "159" ]; then return 1; fi ; }; verify
verify() { if [ "$(grep "Complete and single-copy" $summary_file | sed 's/.*\t\(.*\)\tComplete and single-copy.*/\1/')" != "159" ]; then return 1; fi ; }; verify
verify() { if [ "$(grep "Complete and duplicated" $summary_file | sed 's/.*\t\(.*\)\tComplete and duplicated.*/\1/')" != "0" ]; then return 1; fi ; }; verify
verify() { if [ "$(grep "Fragmented BUSCOs" $summary_file | sed 's/.*\t\(.*\)\tFragmented BUSCOs.*/\1/')" != "2" ]; then return 1; fi ; }; verify
verify() { if [ "$(grep "Missing BUSCOs" $summary_file | sed 's/.*\t\(.*\)\tMissing BUSCOs.*/\1/')" != "33" ]; then return 1; fi ; }; verify
verify() { if [ "$(grep "Total BUSCO groups" $summary_file | sed 's/.*\t\(.*\)\tTotal BUSCO groups.*/\1/')" != "194" ]; then return 1; fi ; }; verify

# Run CI test for archaea autolineage genome pipeline
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/226/975/GCF_000226975.2_ASM22697v3/GCF_000226975.2_ASM22697v3_genomic.fna.gz && gunzip GCF_000226975.2_ASM22697v3_genomic.fna.gz
busco -i GCF_000226975.2_ASM22697v3_genomic.fna --out_path tests/accuracy_tests -o archaea_auto_geno -m geno -c 12 --auto-lineage
summary_file=tests/accuracy_tests/archaea_auto_geno/short_summary.generic.archaea_odb10.archaea_auto_geno.txt
stat $summary_file
verify() { if [ "$(grep "Complete BUSCOs" $summary_file | sed 's/.*\t\(.*\)\tComplete BUSCOs.*/\1/')" != "193" ]; then return 1; fi ; }; verify
verify() { if [ "$(grep "Complete and single-copy" $summary_file | sed 's/.*\t\(.*\)\tComplete and single-copy.*/\1/')" != "193" ]; then return 1; fi ; }; verify
verify() { if [ "$(grep "Complete and duplicated" $summary_file | sed 's/.*\t\(.*\)\tComplete and duplicated.*/\1/')" != "0" ]; then return 1; fi ; }; verify
verify() { if [ "$(grep "Fragmented BUSCOs" $summary_file | sed 's/.*\t\(.*\)\tFragmented BUSCOs.*/\1/')" != "1" ]; then return 1; fi ; }; verify
verify() { if [ "$(grep "Missing BUSCOs" $summary_file | sed 's/.*\t\(.*\)\tMissing BUSCOs.*/\1/')" != "0" ]; then return 1; fi ; }; verify
verify() { if [ "$(grep "Total BUSCO groups" $summary_file | sed 's/.*\t\(.*\)\tTotal BUSCO groups.*/\1/')" != "194" ]; then return 1; fi ; }; verify

summary_file=tests/accuracy_tests/archaea_auto_geno/short_summary.specific.natrialbales_odb10.archaea_auto_geno.txt
stat $summary_file
verify() { if [ "$(grep "Complete BUSCOs" $summary_file | sed 's/.*\t\(.*\)\tComplete BUSCOs.*/\1/')" != "1351" ]; then return 1; fi ; }; verify
verify() { if [ "$(grep "Complete and single-copy" $summary_file | sed 's/.*\t\(.*\)\tComplete and single-copy.*/\1/')" != "1345" ]; then return 1; fi ; }; verify
verify() { if [ "$(grep "Complete and duplicated" $summary_file | sed 's/.*\t\(.*\)\tComplete and duplicated.*/\1/')" != "6" ]; then return 1; fi ; }; verify
verify() { if [ "$(grep "Fragmented BUSCOs" $summary_file | sed 's/.*\t\(.*\)\tFragmented BUSCOs.*/\1/')" != "4" ]; then return 1; fi ; }; verify
verify() { if [ "$(grep "Missing BUSCOs" $summary_file | sed 's/.*\t\(.*\)\tMissing BUSCOs.*/\1/')" != "13" ]; then return 1; fi ; }; verify
verify() { if [ "$(grep "Total BUSCO groups" $summary_file | sed 's/.*\t\(.*\)\tTotal BUSCO groups.*/\1/')" != "1368" ]; then return 1; fi ; }; verify

# Run CI test for archaea autolineage transcriptome pipeline
busco -i tests/accuracy_tests/archaea_auto_geno/prodigal_output/predicted_genes/predicted.fna --out_path tests/accuracy_tests -o archaea_auto_tran -m tran -c 12
summary_file=tests/accuracy_tests/archaea_auto_tran/short_summary.generic.archaea_odb10.archaea_auto_tran.txt
stat $summary_file
verify() { if [ "$(grep "Complete BUSCOs" $summary_file | sed 's/.*\t\(.*\)\tComplete BUSCOs.*/\1/')" != "161" ]; then return 1; fi ; }; verify
verify() { if [ "$(grep "Complete and single-copy" $summary_file | sed 's/.*\t\(.*\)\tComplete and single-copy.*/\1/')" != "161" ]; then return 1; fi ; }; verify
verify() { if [ "$(grep "Complete and duplicated" $summary_file | sed 's/.*\t\(.*\)\tComplete and duplicated.*/\1/')" != "0" ]; then return 1; fi ; }; verify
verify() { if [ "$(grep "Fragmented BUSCOs" $summary_file | sed 's/.*\t\(.*\)\tFragmented BUSCOs.*/\1/')" != "0" ]; then return 1; fi ; }; verify
verify() { if [ "$(grep "Missing BUSCOs" $summary_file | sed 's/.*\t\(.*\)\tMissing BUSCOs.*/\1/')" != "33" ]; then return 1; fi ; }; verify
verify() { if [ "$(grep "Total BUSCO groups" $summary_file | sed 's/.*\t\(.*\)\tTotal BUSCO groups.*/\1/')" != "194" ]; then return 1; fi ; }; verify

summary_file=tests/accuracy_tests/archaea_auto_tran/short_summary.specific.natrialbales_odb10.archaea_auto_tran.txt
stat $summary_file
verify() { if [ "$(grep "Complete BUSCOs" $summary_file | sed 's/.*\t\(.*\)\tComplete BUSCOs.*/\1/')" != "1340" ]; then return 1; fi ; }; verify
verify() { if [ "$(grep "Complete and single-copy" $summary_file | sed 's/.*\t\(.*\)\tComplete and single-copy.*/\1/')" != "1334" ]; then return 1; fi ; }; verify
verify() { if [ "$(grep "Complete and duplicated" $summary_file | sed 's/.*\t\(.*\)\tComplete and duplicated.*/\1/')" != "6" ]; then return 1; fi ; }; verify
verify() { if [ "$(grep "Fragmented BUSCOs" $summary_file | sed 's/.*\t\(.*\)\tFragmented BUSCOs.*/\1/')" != "5" ]; then return 1; fi ; }; verify
verify() { if [ "$(grep "Missing BUSCOs" $summary_file | sed 's/.*\t\(.*\)\tMissing BUSCOs.*/\1/')" != "23" ]; then return 1; fi ; }; verify
verify() { if [ "$(grep "Total BUSCO groups" $summary_file | sed 's/.*\t\(.*\)\tTotal BUSCO groups.*/\1/')" != "1368" ]; then return 1; fi ; }; verify

# Run CI test for bacteria lineage genome pipeline
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/008/865/GCF_000008865.2_ASM886v2/GACF_000008865.2_ASM886v2_genomic.fna.gz && gunzip GCF_000008865.2_ASM886v2_genomic.fna.gz
busco -i GCF_000008865.2_ASM886v2_genomic.fna --out_path tests/accuracy_tests -o bacteria_enterobacterales -m geno -l enterobacterales_odb10 -c 12
summary_file=tests/accuracy_tests/bacteria_enterobacterales/short_summary.specific.enterobacterales_odb10.bacteria_enterobacterales.txt
stat $summary_file
verify() { if [ "$(grep "Complete BUSCOs" $summary_file | sed 's/.*\t\(.*\)\tComplete BUSCOs.*/\1/')" != "440" ]; then return 1; fi ; }; verify
verify() { if [ "$(grep "Complete and single-copy" $summary_file | sed 's/.*\t\(.*\)\tComplete and single-copy.*/\1/')" != "438" ]; then return 1; fi ; }; verify
verify() { if [ "$(grep "Complete and duplicated" $summary_file | sed 's/.*\t\(.*\)\tComplete and duplicated.*/\1/')" != "2" ]; then return 1; fi ; }; verify
verify() { if [ "$(grep "Fragmented BUSCOs" $summary_file | sed 's/.*\t\(.*\)\tFragmented BUSCOs.*/\1/')" != "0" ]; then return 1; fi ; }; verify
verify() { if [ "$(grep "Missing BUSCOs" $summary_file | sed 's/.*\t\(.*\)\tMissing BUSCOs.*/\1/')" != "0" ]; then return 1; fi ; }; verify
verify() { if [ "$(grep "Total BUSCO groups" $summary_file | sed 's/.*\t\(.*\)\tTotal BUSCO groups.*/\1/')" != "440" ]; then return 1; fi ; }; verify

# Run CI test for bacteria autolineage genome pipeline
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/009/065/GCF_000009065.1_ASM906v1/GCF_000009065.1_ASM906v1_genomic.fna.gz && gunzip GCF_000009065.1_ASM906v1_genomic.fna.gz
busco -i GCF_000009065.1_ASM906v1_genomic.fna --out_path tests/accuracy_tests -o bacteria_auto_geno -m geno -c 12 --auto-lineage-prok
summary_file=tests/accuracy_tests/bacteria_auto_geno/short_summary.generic.bacteria_odb10.bacteria_auto_geno.txt
stat $summary_file
verify() { if [ "$(grep "Complete BUSCOs" $summary_file | sed 's/.*\t\(.*\)\tComplete BUSCOs.*/\1/')" != "124" ]; then return 1; fi ; }; verify
verify() { if [ "$(grep "Complete and single-copy" $summary_file | sed 's/.*\t\(.*\)\tComplete and single-copy.*/\1/')" != "124" ]; then return 1; fi ; }; verify
verify() { if [ "$(grep "Complete and duplicated" $summary_file | sed 's/.*\t\(.*\)\tComplete and duplicated.*/\1/')" != "0" ]; then return 1; fi ; }; verify
verify() { if [ "$(grep "Fragmented BUSCOs" $summary_file | sed 's/.*\t\(.*\)\tFragmented BUSCOs.*/\1/')" != "0" ]; then return 1; fi ; }; verify
verify() { if [ "$(grep "Missing BUSCOs" $summary_file | sed 's/.*\t\(.*\)\tMissing BUSCOs.*/\1/')" != "0" ]; then return 1; fi ; }; verify
verify() { if [ "$(grep "Total BUSCO groups" $summary_file | sed 's/.*\t\(.*\)\tTotal BUSCO groups.*/\1/')" != "124" ]; then return 1; fi ; }; verify

summary_file=tests/accuracy_tests/bacteria_auto_geno/short_summary.specific.enterobacterales_odb10.bacteria_auto_geno.txt
stat $summary_file
verify() { if [ "$(grep "Complete BUSCOs" $summary_file | sed 's/.*\t\(.*\)\tComplete BUSCOs.*/\1/')" != "439" ]; then return 1; fi ; }; verify
verify() { if [ "$(grep "Complete and single-copy" $summary_file | sed 's/.*\t\(.*\)\tComplete and single-copy.*/\1/')" != "438" ]; then return 1; fi ; }; verify
verify() { if [ "$(grep "Complete and duplicated" $summary_file | sed 's/.*\t\(.*\)\tComplete and duplicated.*/\1/')" != "1" ]; then return 1; fi ; }; verify
verify() { if [ "$(grep "Fragmented BUSCOs" $summary_file | sed 's/.*\t\(.*\)\tFragmented BUSCOs.*/\1/')" != "1" ]; then return 1; fi ; }; verify
verify() { if [ "$(grep "Missing BUSCOs" $summary_file | sed 's/.*\t\(.*\)\tMissing BUSCOs.*/\1/')" != "0" ]; then return 1; fi ; }; verify
verify() { if [ "$(grep "Total BUSCO groups" $summary_file | sed 's/.*\t\(.*\)\tTotal BUSCO groups.*/\1/')" != "440" ]; then return 1; fi ; }; verify
