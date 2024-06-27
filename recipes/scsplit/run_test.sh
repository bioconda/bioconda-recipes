#!/bin/bash

set -e

scSplit count -v donor_genotype_chr21.vcf -i chr21.bam -b barcodes.tsv -r ref_filtered.csv -a alt_filtered.csv -o .
