#!/bin/bash
# No pipefail: it would leak into the recipe's `test: commands:` and break them
set -ex

disassembler msa \
    --ref tests/fixture_query.fasta \
    --input tests/fixture_reconstructed.fasta \
    --out-aln aln.fasta \
    --out-tree tree.nwk \
    --mafft-threads 1

test -s aln.fasta
test -s tree.nwk
