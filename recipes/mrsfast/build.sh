#!/bin/bash
export CPATH=${PREFIX}/include
export CC="${CC} -fcommon"
export CXX="${CXX} -fcommon"
export CFLAGS="${CFLAGS} -fcommon"
export CXXFLAGS="${CXXFLAGS} -fcommon"
make with-sse4=no
mkdir -p ${PREFIX}/bin
cp -f mrsfast ${PREFIX}/bin
./mrsfast --help
