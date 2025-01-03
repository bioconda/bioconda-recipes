#!/bin/bash

CXXFLAGS="${CXXFLAGS} -D__STDC_FORMAT_MACROS -O3 -I${PREFIX}/include" make -j"${CPU_COUNT}" CXX="${CXX}" prefix="${PREFIX}" install
