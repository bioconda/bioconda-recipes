#!/bin/bash

CXXFLAGS="${CXXFLAGS} -O3 -D__STDC_FORMAT_MACROS -I${PREFIX}/include -L${PREFIX}/lib" make -j"${CPU_COUNT}" CXX="${CXX}" HTSLIBINCDIR="${PREFIX}/include" HTSLIBLIBDIR="${PREFIX}/lib" prefix="${PREFIX}" install
