#!/bin/bash

set -exuo pipefail

mkdir -p ${PREFIX}/share/privateer/data/linkage_torsions

cp \
    data/linkage_torsions/privateer_torsion_database.json \
    ${PREFIX}/share/privateer/data/linkage_torsions

privateer \
    -pdbin tests/test_data/5fjj.pdb \
    -mtzin tests/test_data/5fjj.mtz
