#!/bin/bash
set -exu

export LIBCIFPP_DATA_DIR="${CONDA_PREFIX}/share/libcifpp"
test -f "$PREFIX/share/libcifpp/mmcif_pdbx.dic" || find "$PREFIX" -name 'mmcif_pdbx.dic'

# pdb2cif fails on duplicate `_refine` keys in PDB files
pdb2cif 7f95_flipper.pdb || true

cif2pdb 1cbs_final.cif
cif-diff --editor=terminal 443d_final.cif 7f95-carb.cif || true
cif-merge 443d_final.cif 7f95-carb.cif
cif-validate 443d_final.cif
mmcql -f test.cql 443d_final.cif
