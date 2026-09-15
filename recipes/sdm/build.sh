#!/bin/bash
set -xe

mkdir -p "${PREFIX}/bin"

# https://bioconda.github.io/contributor/troubleshooting.html#zlib-errors
export CFLAGS="${CFLAGS} -O3 -I$PREFIX/include"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib"

# Link dynamically against the htslib/zlib provided by the host environment
# instead of the upstream default of a fully static build.
make -j"${CPU_COUNT}" STATIC=0

install -v -m 755 sdm "${PREFIX}/bin"
