#!/usr/bin/env bash

set -x
set -e

# Skip if aarch64 on linux
# Because Nextclade requires glibc >= 2.18 not available yet on aarch64 builder
if [[ $target_platform == linux-aarch64 ]]; then
    echo "Skipping test on aarch64"
    exit 0
fi

nextclade2 --version

nextclade2 dataset get --name 'sars-cov-2' --output-dir 'data/sars-cov-2'

nextclade2 run \
--input-dataset 'data/sars-cov-2' \
'data/sars-cov-2/sequences.fasta' \
--output-tsv 'output/nextclade.tsv' \
--output-tree 'output/tree.json' \
--output-all 'output/'

rm -rf data output
