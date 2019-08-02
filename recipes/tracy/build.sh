#!/bin/sh

rmdir ${SRC_DIR}/tracy/src/xxsds/
mv ${SRC_DIR}/sdsl-lite ${SRC_DIR}/tracy/src/xxsds
cd ${SRC_DIR}/tracy
ls -lhR

make all CXX=$CXX
mkdir -p $PREFIX/bin
cp src/tracy $PREFIX/bin
