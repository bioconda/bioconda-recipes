#!/bin/bash

set -euo pipefail

set -euxo pipefail

# Test archaea genome mode
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/091/665/GCF_000091665.1_ASM9166v1/GCF_000091665.1_ASM9166v1_genomic.fna.gz && gunzip 
GCF_000091665.1_ASM9166v1_genomic.fna.gz
busco -i GCF_000091665.1_ASM9166v1_genomic.fna --out_path tests/accuracy_tests -o archaea_methanococcales -m geno -l methanococcales_odb10 -c 4
stat tests/accuracy_tests/archaea_methanococcales/short_summary*

# Test archaea transcriptome mode
busco -i tests/accuracy_tests/archaea_methanococcales/prodigal_output/predicted_genes/predicted.fna --out_path tests/accuracy_tests -o archaea_archaea -m tran -l 
archaea_odb10 -c 4
stat tests/accuracy_tests/archaea_archaea/short_summary*

# Test bacteria protein mode
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/009/065/GCF_000009065.1_ASM906v1/GCF_000009065.1_ASM906v1_protein.faa.gz && gunzip 
GCF_000009065.1_ASM906v1_protein.faa.gz
busco -i GCF_000009065.1_ASM906v1_protein.faa --out_path tests/accuracy_tests -o bacteria_mollicutes -m prot -l mollicutes_odb10 -c 4
stat tests/accuracy_tests/bacteria_mollicutes/short_summary*

# Test eukaryota genome mode
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/215/GCF_000001215.4_Release_6_plus_ISO1_MT/GCF_000001215.4_Release_6_plus_ISO1_MT_genomic.fna.gz && gunzip 
GCF_000001215.4_Release_6_plus_ISO1_MT_genomic.fna.gz
busco -i GCF_000001215.4_Release_6_plus_ISO1_MT_genomic.fna --out_path tests/accuracy_tests -o eukaryota_diptera -m geno -l diptera_odb10 -c 4
stat tests/accuracy_tests/eukaryota_diptera/short_summary*

