#!/usr/bin/env bash

set -x
set -e

nextclade2 --version

nextclade2 dataset get --name 'sars-cov-2' --output-dir 'data/sars-cov-2'

nextclade2 run \
--input-dataset 'data/sars-cov-2' \
'data/sars-cov-2/sequences.fasta' \
--output-tsv 'output/nextclade.tsv' \
--output-tree 'output/tree.json' \
--output-all 'output/'

rm -rf data output
