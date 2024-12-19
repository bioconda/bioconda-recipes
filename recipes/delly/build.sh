#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

make -j"${CPU_COUNT}" CXX="${CXX}" prefix="${PREFIX}" CXXFLAGS="${CXXFLAGS} -D__STDC_FORMAT_MACROS -O3 -I${PREFIX}/include" install
