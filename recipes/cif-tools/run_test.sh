#!/bin/bash
set -exu

pdb2cif 7f95_flipper.pdb || true

# buggy commands
cif2pdb 1cbs_final.cif || true
cif-diff 443d_final.cif 7f95-carb.cif || true

cif-merge 443d_final.cif 7f95-carb.cif || true
cif-validate 443d_final.cif || true
mmcql -f test.cql 443d_final.cif
