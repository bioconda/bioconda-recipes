#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

CXXFLAGS="${CXXFLAGS} -D__STDC_FORMAT_MACROS -I${SRC_DIR}/src/sdslLite/include -L${SRC_DIR}/src/sdslLite/lib -I${PREFIX}/include -L${PREFIX}/lib -Isrc/jlib/ -std=c++17" make -j"${CPU_COUNT}" CXX="${CXX}" prefix="${PREFIX}" install
