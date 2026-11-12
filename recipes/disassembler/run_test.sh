#!/bin/bash
# Smoke test for the MAFFT path.
#
# This lives here rather than in `test: commands:` because bioconda-utils reuses the commands
# list verbatim for the mulled container test, and the container has no source tree, so a
# command referencing `tests/...` fails there with ENOENT. `source_files` are staged only for
# this script's run, which is conda-build's own test phase.
#
# `disassembler msa` runs `mafft --auto --keeplength --addfragments` and then FastTree. It
# re-reads its own output and exits non-zero unless every aligned row is the reference's
# length, so a MAFFT that mishandles --addfragments (the 7.525 bug that the `mafft >=7.526`
# run requirement guards against) fails this script rather than passing CI.

set -euxo pipefail

disassembler msa \
    --ref tests/fixture_query.fasta \
    --input tests/fixture_reconstructed.fasta \
    --out-aln aln.fasta \
    --out-tree tree.nwk \
    --mafft-threads 1

# Reaching here already proves --keeplength held; assert the outputs exist and are non-empty.
test -s aln.fasta
test -s tree.nwk
