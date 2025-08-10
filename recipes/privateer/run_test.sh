#!/bin/bash

set -exuo pipefail

privateer \
    -pdbin tests/test_data/5fjj.pdb \
    -mtzin tests/test_data/5fjj.mtz \
    -all_permutations \
    -debug
