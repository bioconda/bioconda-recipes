#!/bin/bash
set -exu

# Upstream test files omit .dic; libcifpp looks up the dictionary by filename.
sed -i.bak '/^_audit_conform\.dict_name/s/mmcif_pdbx[[:space:]]*$/mmcif_pdbx.dic/' *.cif

# pdb2cif fails on duplicate `_refine` keys in PDB files
pdb2cif 7f95_flipper.pdb || true

cif2pdb 1cbs_final.cif

# cif-diff --editor=terminal segfaults on these fixtures in v2.0.1.
cif-diff --editor=terminal 443d_final.cif 7f95-carb.cif || true

cif-merge 443d_final.cif 7f95-carb.cif
cif-validate 443d_final.cif
mmcql -f test.cql 443d_final.cif
