#!/bin/bash
set -euo pipefail

# The upstream Makefile hardcodes /usr/local for include and lib paths and
# pins CC=g++. Override those to use the conda-provided toolchain and the
# host environment's headers/libs under $PREFIX.

make \
    CC="${CXX} -std=c++11" \
    CFLAGS="${CXXFLAGS:-} -O3 ${CPPFLAGS:-}" \
    INCLFLAGS="-I${PREFIX}/include" \
    LIBFLAGS="${LDFLAGS:-} -L${PREFIX}/lib"

install -d "${PREFIX}/bin"
install -m 0755 BA3 "${PREFIX}/bin/BA3"
