#!/usr/bin/env bash

set -euxo pipefail

nextalign run \
test-data/sequences.fasta \
--reference test-data/reference.fasta \
--genemap test-data/genemap.gff \
--output-all output/ \
--output-basename nextalign
