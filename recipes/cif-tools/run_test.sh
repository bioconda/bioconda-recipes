#!/bin/bash
set -exu

pdb2cif 7f95_flipper.pdb || true

# buggy commands
cif2pdb 1cbs_final.cif
cif-diff 443d_final.cif 7f95-carb.cif

cif-grep 'STRUCTURES OF M-IODO HOECHST-DNA COMPLEXES' 443d_final.cif
cif-merge 443d_final.cif 7f95-carb.cif || true
cif-validate 443d_final.cif || true
mmCQL -f test.cql 443d_final.cif
