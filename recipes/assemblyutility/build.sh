#!/bin/bash

mkdir -p "${PREFIX}/bin"

"${CXX}" ${CPPFLAGS} ${CXXFLAGS} -O3 \
    -o "${PREFIX}/bin/"AssemblyStatistics AssemblyStatistics.cpp \
    ${LDFLAGS}

"${CXX}" ${CPPFLAGS} ${CXXFLAGS} -O3 \
    -o "${PREFIX}/bin/"SelectLongestReads SelectLongestReads.cpp \
    ${LDFLAGS}
