#!/usr/bin/env bash

set -euxo pipefail

if [ $(uname) == "Linux" ]; then
    ARCH=$(uname -m)
    export LD_LIBRARY_PATH="${PREFIX}/${ARCH}-conda-linux-gnu/sysroot/usr/lib64"
    export PATH="${PREFIX}/${ARCH}-conda-linux-gnu/sysroot/usr/bin:${PATH}"
    ldd --version
fi

nextalign run \
    test-data/sequences.fasta \
    --reference test-data/reference.fasta \
    --genemap test-data/genemap.gff \
    --output-all output/ \
    --output-basename nextalign
