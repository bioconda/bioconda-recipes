#!/bin/bash
set -euo pipefail

make clean || true

make -j"${CPU_COUNT}" \
    CC="${CC}" \
    CXX="${CXX}" \
    LIBS="${SRC_DIR}/lib/libminimap2.a -lz -lpthread -lm" \
    VERBOSE=1

mkdir -p "${PREFIX}/bin"
install -m 0755 HapFold "${PREFIX}/bin/HapFold"

mkdir -p "${PREFIX}/bin/build"
install -m 0755 \
    build/libhifiasm_embedded.so \
    "${PREFIX}/bin/build/libhifiasm_embedded.so"

ln -sf HapFold "${PREFIX}/bin/hapfold"
