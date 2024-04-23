#!/usr/bin/env bash

set -euxo pipefail

ldd --version
which ldd
ls -laR ${PREFIX}
export LD_LIBRARY_PATH="${PREFIX}/lib:${LD_LIBRARY_PATH}"

if [ $(uname -m) != "aarch64" ]; then

    nextalign run \
        test-data/sequences.fasta \
        --reference test-data/reference.fasta \
        --genemap test-data/genemap.gff \
        --output-all output/ \
        --output-basename nextalign
        
fi
