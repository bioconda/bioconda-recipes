#!/bin/bash

Helixer/scripts/fetch_helixer_models.py
cd shared/out/
curl -L ftp://ftp.ensemblgenomes.org/pub/plants/release-47/fasta/arabidopsis_lyrata/dna/Arabidopsis_lyrata.v.1.0.dna.chromosome.8.fa.gz --output Arabidopsis_lyrata.v.1.0.dna.chromosome.8.fa.gz
Helixer.py --fasta-path Arabidopsis_lyrata.v.1.0.dna.chromosome.8.fa.gz --lineage land_plant --gff-output-path Arabidopsis_lyrata_chromosome8_helixer.gff3
head Arabidopsis_lyrata_chromosome8_helixer.gff3