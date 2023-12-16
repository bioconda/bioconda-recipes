#!/usr/bin/env bash

set -x
set -e

nextclade3 --version

nextclade3 dataset get --name 'sars-cov-2' --output-dir 'data/sars-cov-2'

nextclade3 run \
--input-dataset 'data/sars-cov-2' \
'data/sars-cov-2/sequences.fasta' \
--output-tsv 'output/nextclade.tsv' \
--output-tree 'output/tree.json' \
--output-all 'output/'

rm -rf data output
