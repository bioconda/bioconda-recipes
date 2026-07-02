#!/bin/bash
set -ex

# The Makefile defaults CC to literal `gcc`, which does not exist in the conda/bioconda
# build environment (only the activated cross-compiler $CC = x86_64-conda-linux-gnu-gcc).
# PORTABLE=1 drops -march=native so the binary is safe across CPUs/containers.
make PORTABLE=1 CC="${CC:-gcc}" -j "${CPU_COUNT}"

mkdir -p "$PREFIX/bin"
[ -x bin/mdl-repeat ] || { echo "mdl-repeat binary not produced" >&2; exit 1; }
install -m 0755 bin/mdl-repeat "$PREFIX/bin/mdl-repeat"
