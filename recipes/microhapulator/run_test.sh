#!/usr/bin/env bash
set -eo pipefail

wget -O hg38.fasta.gz http://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/hg38.fa.gz
gunzip hg38.fasta.gz
faidx hg38.fasta chr1:100-150 > /dev/null

pytest -m 'not known_failing' --cov=microhapulator --pyargs microhapulator

rm -f hg38.fasta
