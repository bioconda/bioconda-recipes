#!/bin/bash
set -x -e
mkdir -p "${PREFIX}/bin"
INCLUDES="-I${PREFIX}/include -I${BUILD_PREFIX}/include -I${BUILD_PREFIX}/include/bamtools"
LDADD="${BUILD_PREFIX}/lib/libbamtools.a ${BUILD_PREFIX}/lib/libglpk.a -L${PREFIX}/lib"
${CXX} -std=c++11 ${CXXFLAGS} $INCLUDES -o $PREFIX/bin/squid src/*.cpp $LDADD -lz -lm
