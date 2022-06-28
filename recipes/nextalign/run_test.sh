#!/usr/bin/env bash

set -euxo pipefail

nextalign \
test-data/sequences.fasta \
--reference test-data/reference.fasta \
--genemap test-data/genemap.gff \
--output-dir output/ \
--output-basename nextalign
