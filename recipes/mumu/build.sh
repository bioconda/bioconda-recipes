#!/bin/bash
set -euo pipefail

# ${CXX} = gxx_linux-64 / clangxx_osx-64
export CXX="${CXX}"

# Build with the parallelism conda-build gives us
make -j"${CPU_COUNT}" CXX="${CXX}" PREFIX="${PREFIX}"

# run the test suite? not needed
# bash ./tests/mumu.sh ./mumu | grep -q "FAIL" && { echo "tests failed"; exit 1; } || true

# install binary and manpage
make install PREFIX="${PREFIX}"
