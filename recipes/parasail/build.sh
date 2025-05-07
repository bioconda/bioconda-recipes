#!/usr/bin/env bash

set -euo pipefail

if [[ "$(uname)" == "Linux" ]]; then
    sed -i.bak 's/ref_trace_table = parasail_result/ref_trace_table = (int8_t *)parasail_result/' tests/test_verify_traces.c
    sed -i.bak 's/size_a, size_b, ref_trace_table, trace_table/size_a, size_b, (int8_t *)ref_trace_table, (int8_t *)trace_table/' tests/test_verify_traces.c
fi

autoreconf -fvi

./configure \
    --prefix="${PREFIX}" \
    --with-zlib \
    CC="${CC}" \
    CXX="${CXX}" \
    CFLAGS="${CFLAGS}" \
    CXXFLAGS="${CXXFLAGS}" \
    LDFLAGS="${LDFLAGS}"

make -j${CPU_COUNT}
make check
make install
