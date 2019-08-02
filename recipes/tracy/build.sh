#!/bin/sh

rmdir ${SRC_DIR}/src/xxsds/
mv ${SRC_DIR}/sdsl-lite ${SRC_DIR}/src/xxsds

make all CXX=$CXX CXXFLAGS="-D__STDC_FORMAT_MACROS -I${SRC_DIR}/src/sdslLite/include"
mkdir -p $PREFIX/bin
cp src/tracy $PREFIX/bin
