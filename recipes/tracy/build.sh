#!/bin/sh

rmdir ${SRC_DIR}/tracy/src/xxsds/
mv ${SRC_DIR}/sdsl-lite ${SRC_DIR}/tracy/src/xxsds
cd ${SRC_DIR}/tracy

export SDSL_ROOT=${SRC_DIR}/tracy/src/sdslLite/
make all CXX=$CXX CXXFLAGS="-D__STDC_FORMAT_MACROS -I${SRC_DIR}/tracy/src/sdslLite/include"
mkdir -p $PREFIX/bin
cp src/tracy $PREFIX/bin
