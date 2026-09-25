#!/bin/bash
set -euo pipefail

cd src
# Override CXX on the make command line: the upstream Makefile hard-codes
# `CXX = g++`, which shadows the $CXX env var that conda's compiler
# activation script sets. On bioconda CI there is no bare `g++` on PATH,
# only $BUILD_PREFIX/bin/x86_64-conda-linux-gnu-c++, so the build fails
# without this override.
make -j "${CPU_COUNT}" CXX="${CXX}"

mkdir -p "${PREFIX}/bin"
install -m 0755 ../bin/palmscan2 "${PREFIX}/bin/palmscan2"
