#!/bin/bash
set -euo pipefail

# src/Makefile reads CXX, CXXFLAGS, CPPFLAGS and LDFLAGS from the
# environment, so conda's compiler and the zlib in $PREFIX are used.
make -C src -j"${CPU_COUNT}" CXXFLAGS="${CXXFLAGS} -O3"

# Regression suite (about 30 s); needs bash, awk, gzip, cmp and diff.
make -C src check

make -C src install PREFIX="${PREFIX}"
