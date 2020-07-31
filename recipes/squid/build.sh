#!/bin/bash
set -x
mkdir -p "${PREFIX}/bin"
LDADD="${PREFIX}/lib/libbamtools.a ${PREFIX}/lib/libglpk.a"
LDLIBS='-lz -lm'
"${CXX}" \
    ${CPPFLAGS} ${CXXFLAGS} -I"${PREFIX}/include/bamtools" -std=c++11 \
    -o "${PREFIX}/bin/squid" src/*.cpp \
    ${LDFLAGS} ${LDADD} ${LDLIBS}
