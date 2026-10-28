#!/bin/bash

if [[ "$(uname -s)" == "Darwin" ]]; then
    export LDFLAGS="${LDFLAGS} -headerpad_max_install_names"
fi

CXXFLAGS="${CXXFLAGS} -O3 -D__STDC_FORMAT_MACROS -I${PREFIX}/include -std=c++17" LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -pthread" make -j${CPU_COUNT} CXX="${CXX}" prefix="${PREFIX}" install
