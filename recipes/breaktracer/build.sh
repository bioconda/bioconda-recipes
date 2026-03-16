#!/bin/bash

CXXFLAGS="${CXXFLAGS} -O3 -D__STDC_FORMAT_MACROS -I${PREFIX}/include -L${PREFIX}/lib -std=c++17" make -j${CPU_COUNT} CXX="${CXX}" prefix="${PREFIX}" install
