#!/bin/sh

set -o errexit -o nounset

# PASA requires "fasta" to be a symlink to the fasta3? binary
ln -s ${PREFIX}/bin/fasta36 ${PREFIX}/bin/fasta
