#!/bin/sh

CXXFLAGS="${CXXFLAGS} -D__STDC_FORMAT_MACROS -I${PREFIX}/include -L${PREFIX}/lib" make -j${CPU_COUNT} CXX="${CXX}" prefix="${PREFIX}" install
