#!/usr/bin/env bash

set -euxo pipefail

ls -la ${PREFIX}/lib
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${PREFIX}/lib"

nextalign run \
test-data/sequences.fasta \
--reference test-data/reference.fasta \
--genemap test-data/genemap.gff \
--output-all output/ \
--output-basename nextalign
