#!/bin/sh

rmdir ${SRC_DIR}/tracy/src/xxsds/
mv ${SRC_DIR}/sdsl-lite ${SRC_DIR}/tracy/src/xxsds
cd ${SRC_DIR}/tracy

make all CXX=$CXX CXXFLAGS="-D__STDC_FORMAT_MACROS"
mkdir -p $PREFIX/bin
cp src/tracy $PREFIX/bin
