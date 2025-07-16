#!/usr/bin/env bash

set -euxo pipefail

# the binary needs GLIBC 2.18+ on Linux ARM64 while 2.17 is available
if [ $(uname -m) != "aarch64" ]; then

nextalign run \
    test-data/sequences.fasta \
    --reference test-data/reference.fasta \
    --genemap test-data/genemap.gff \
    --output-all output/ \
    --output-basename nextalign

fi