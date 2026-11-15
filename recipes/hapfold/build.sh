#!/bin/bash
set -euo pipefail

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/bin/build"

make clean || true

make -j"${CPU_COUNT}" \
    CC="${CC}" \
    CXX="${CXX}" \
    LIBS="${SRC_DIR}/lib/libminimap2.a -lz -pthread -lm" \
    VERBOSE=1

install -v -m 0755 HapFold "${PREFIX}/bin"

install -v -m 0755 build/libhifiasm_embedded.so \
    "${PREFIX}/bin/build/libhifiasm_embedded.so"

ln -sf HapFold "${PREFIX}/bin/hapfold"
