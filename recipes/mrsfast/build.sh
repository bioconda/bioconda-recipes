#!/bin/bash
export CPATH=${PREFIX}/include
export CFLAGS="${CFLAGS} -fcommon"
export CXXFLAGS="${CXXFLAGS} -fcommon"
make with-sse4=no
mkdir -p ${PREFIX}/bin
cp -f mrsfast ${PREFIX}/bin
./mrsfast --help
