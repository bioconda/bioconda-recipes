#!/bin/bash

set -xe

make all CXX=$CXX CXXFLAGS="-D__STDC_FORMAT_MACROS -I${SRC_DIR}/src/sdslLite/include -L${SRC_DIR}/src/sdslLite/lib -I${PREFIX}/include -L${PREFIX}/lib -Isrc/jlib/ -std=c++14" -j ${CPU_COUNT}
mkdir -p $PREFIX/bin
cp src/tracy $PREFIX/bin
