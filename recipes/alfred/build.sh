#!/bin/bash

CXXFLAGS="${CXXFLAGS} -O3 -D__STDC_FORMAT_MACROS -I${PREFIX}/include -std=c++17" LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -pthread"  make -j${CPU_COUNT} CXX="${CXX}" prefix="${PREFIX}" install
