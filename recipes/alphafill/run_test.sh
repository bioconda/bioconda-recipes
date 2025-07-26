#!/bin/bash

set -exo pipefail

export LIBCIFPP_DATA_DIR="${PREFIX}/share/libcifpp"

cat <<EOF > alphafill.conf
pdb-dir=test/mini-pdb-redo/
pdb-fasta=pdb-redo.fa
ligands=${PREFIX}/share/alphafill/af-ligands.cif
EOF

alphafill create-index
grep -q ">pdb-entity|2CBS|1|R13" pdb-redo.fa
alphafill process --config alphafill.conf \
    test/afdb-v4/P2/AF-P29373-F1-model_v4.cif.gz \
    out.cif.gz
test -f out.cif.gz
gunzip -c out.cif.gz > out.cif
grep 'RETINOIC ACID' out.cif
