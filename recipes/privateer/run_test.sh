#!/bin/bash

set -exuo pipefail

privateer \
    -pdbin tests/test_data/5fjj.pdb \
    -mtzin tests/test_data/5fjj.mtz \
    -glytoucan \
    -databasein data/glycomics/privateer_glycomics_database.json \
    -debug_output \
    -all_permutations
