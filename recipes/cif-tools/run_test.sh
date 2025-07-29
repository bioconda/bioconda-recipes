#!/bin/bash

set -exu

pdb2cif 7f95-carb.pdb
cif2pdb 7f95-carb.cif
cif-diff 443d_final.cif 7f95-carb.cif
cif-grep 'STRUCTURES OF M-IODO HOECHST-DNA COMPLEXES' 443d_final.cif

set +e
cif-merge 443d_final.cif 7f95-carb.cif || true
cif-validate 443d_final.cif || true
set -e

mmCQL -f test.cql 443d_final.cif
