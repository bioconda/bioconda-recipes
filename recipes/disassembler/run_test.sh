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

# Deliberately NOT `set -o pipefail`: conda-build runs this script and the `test: commands:`
# list in the same shell (conda_test_runner.sh), so any shell option set here leaks into those
# commands. With pipefail, `l1_pipeline_serial 2>&1 | grep -q -- "--input required"` fails,
# because the binary exits 1 while printing that usage error and the test relies on the
# pipeline returning grep's status. `set -ex` matches what conda-build sets for the commands.
set -ex

disassembler msa \
    --ref tests/fixture_query.fasta \
    --input tests/fixture_reconstructed.fasta \
    --out-aln aln.fasta \
    --out-tree tree.nwk \
    --mafft-threads 1

# Reaching here already proves --keeplength held; assert the outputs exist and are non-empty.
test -s aln.fasta
test -s tree.nwk
