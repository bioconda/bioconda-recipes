#!/bin/bash

set -exuo pipefail

privateer \
    -pdbin tests/test_data/5fjj.pdb \
    -mtzin tests/test_data/5fjj.mtz \
    -glytoucan \
    -databasein src/privateer/privateer_database.json \
    -debug_output \
    -all_permutations
