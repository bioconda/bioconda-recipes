#!/bin/bash
set -ex

# The Makefile builds the vendored minimap2 and htsbox/htslib (third_party/),
# which conda places from the pinned submodule commits listed in meta.yaml.
# CPPFLAGS is not overridden: the sub-makes rely on their own CPPFLAGS
# (e.g. minimap2's -DHAVE_KALLOC). Conda include/library paths are passed
# through the compiler variables so that every sub-make sees zlib.
export CC="${CC} -I${PREFIX}/include -L${PREFIX}/lib"
export CXX="${CXX} -I${PREFIX}/include -L${PREFIX}/lib"
unset CPPFLAGS

make -j"${CPU_COUNT}" DipGenie \
    CC="${CC}" \
    CXX="${CXX}" \
    AR="${AR}" \
    CXXFLAGS="-O3 -std=c++17 -pthread -fopenmp" \
    LDLIBS="-lz -lm -pthread"

mkdir -p "${PREFIX}/bin"
install -m 755 DipGenie "${PREFIX}/bin/DipGenie"
