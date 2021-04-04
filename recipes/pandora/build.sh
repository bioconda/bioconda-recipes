#!/bin/bash
set -eu -o pipefail

alias gcc=$GCC
alias g++=$CXX
mkdir -p build
cd build
cmake -DCMAKE_BUILD_TYPE=Release \
      -DPRINT_STACKTRACE=True \
      -DCMAKE_INSTALL_PREFIX="$PREFIX" \
      ..
make VERBOSE=1
ctest -VV
make install
