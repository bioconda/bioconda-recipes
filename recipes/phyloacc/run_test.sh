#!/bin/bash
set -e
set -o pipefail
set -x

# Runs test for PhyloAcc, including on a small simulated dataset that contains a fasta file, mod file,
# bed file, id subset file, and config file.

TMP=$(mktemp -d)
cd $TMP

echo " ** DOWNLOADING TEST DATA."
wget https://github.com/phyloacc/PhyloAcc-test-data/raw/main/bioconda-test-data/bioconda-test-cfg.yaml
wget https://github.com/phyloacc/PhyloAcc-test-data/raw/main/bioconda-test-data/id-subset.txt
wget https://github.com/phyloacc/PhyloAcc-test-data/raw/main/bioconda-test-data/ratite.mod
wget https://github.com/phyloacc/PhyloAcc-test-data/raw/main/bioconda-test-data/simu_500_200_diffr_2-1.bed
wget https://github.com/phyloacc/PhyloAcc-test-data/raw/main/bioconda-test-data/simu_500_200_diffr_2-1.noanc.fa
echo " ** TEST DATA DOWNLOAD OK."

echo " ** BEGIN DEPCHECK TEST."
phyloacc --depcheck
echo " ** DEPCHECK TEST OK."

echo " ** BEGIN PHYLOACC INTERFACE TEST."
phyloacc --config bioconda-test-cfg.yaml --local
echo " ** INTERFACE TEST OK."

echo " ** BEGIN WORKFLOW TEST."
snakemake -p --jobs 1 --cores 1 -s phyloacc-bioconda-test/phyloacc-job-files/snakemake/run_phyloacc.smk --configfile phyloacc-bioconda-test/phyloacc-job-files/snakemake/phyloacc-config.yaml
echo " ** WORKFLOW TEST OK."

echo " ** BEGIN POST-PROCESSING TEST."
phyloacc_post.py -h
phyloacc_post.py -i phyloacc-bioconda-test/
echo " ** POST-PROCESSING TEST OK."