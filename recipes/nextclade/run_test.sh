#!/usr/bin/env bash

set -x
set -e

MAJOR_VERSION=$(echo "$PKG_VERSION" | cut -d. -f1)

# Print glibc versions
# if on linux
if [[ $target_platform == linux* ]]; then
    ldd --version
    strings /usr/lib64/libc.so.6 | grep -E "^GLIBC_2"
fi

for BIN in nextclade nextclade$MAJOR_VERSION; do
    "$BIN" --version

    "$BIN" dataset get --name 'sars-cov-2' --output-dir 'data/sars-cov-2'

    "$BIN" run \
    --input-dataset 'data/sars-cov-2' \
    'data/sars-cov-2/sequences.fasta' \
    --output-tsv 'output/nextclade.tsv' \
    --output-tree 'output/tree.json' \
    --output-all 'output/'

    rm -rf data output

done
