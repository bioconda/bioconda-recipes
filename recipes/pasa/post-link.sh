#!/bin/sh

set -o errexit -o nounset

# PASA requires "fasta" to be a symlink to the fasta3? binary
readonly PASAHOME=${PREFIX}/opt/pasa-${PKG_VERSION}
cd ${PASAHOME}/bin
ln -s ../../../bin/fasta3? fasta
