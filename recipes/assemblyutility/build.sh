#!/bin/bash

mkdir -p "${PREFIX}/bin"

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

"${CXX}" ${CPPFLAGS} ${CXXFLAGS} -O3 \
    -o "${PREFIX}/bin/"AssemblyStatistics AssemblyStatistics.cpp \
    ${LDFLAGS}

"${CXX}" ${CPPFLAGS} ${CXXFLAGS} -O3 \
    -o "${PREFIX}/bin/"SelectLongestReads SelectLongestReads.cpp \
    ${LDFLAGS}
