#!/bin/bash
set -xe

cd 1.9

# The source tarball carries the SIMD Everywhere headers in 2.0/simde, which
# the non-x86 builds need.
export CFLAGS="${CFLAGS} ${CPPFLAGS} -Wall -O2 -I../2.0/simde"
export CXXFLAGS="${CXXFLAGS} ${CPPFLAGS} -Wall -O2 -I../2.0/simde"

args=(CC="${CC}" CXX="${CXX}" ZLIB="-L${PREFIX}/lib -lz")
if [[ "$(uname)" != "Darwin" ]]; then
  # OpenBLAS ships LAPACK, so a single -lopenblas replaces the ATLAS default.
  args+=(BLASFLAGS="-L${PREFIX}/lib -lopenblas" LDFLAGS="${LDFLAGS} -lm -lpthread -ldl")
fi

make -j"${CPU_COUNT}" "${args[@]}"

mkdir -p "${PREFIX}/bin"
install -m 755 plink "${PREFIX}/bin/"
