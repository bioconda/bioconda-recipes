#!/usr/bin/env bash

set -x
set -e

nextclade dataset get --name 'sars-cov-2' --output-dir 'data/sars-cov-2'

nextclade run \
--input-dataset 'data/sars-cov-2' \
--input-fasta 'data/sars-cov-2/sequences.fasta' \
--output-tsv 'output/nextclade.tsv' \
--output-tree 'output/tree.json' \
--output-dir 'output/'
