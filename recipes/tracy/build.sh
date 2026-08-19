#!/bin/bash

CXXFLAGS="${CXXFLAGS} -O3 -D__STDC_FORMAT_MACROS -I${SRC_DIR}/src/sdslLite/include -L${SRC_DIR}/src/sdslLite/lib -I${PREFIX}/include -L${PREFIX}/lib -Isrc/jlib/" make -j${CPU_COUNT} CXX="${CXX}" prefix="${PREFIX}" install
