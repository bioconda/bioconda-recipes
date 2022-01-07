#!/usr/bin/env bash

set -euxo pipefail

nextalign \
--sequences test-data/sequences.fasta \
--reference test-data/reference.fasta \
--genemap test-data/genemap.gff \
--genes E,M,N,ORF1a,ORF1b,ORF3a,ORF6,ORF7a,ORF7b,ORF8,ORF9b,S \
--output-dir output/ \
--output-basename nextalign
