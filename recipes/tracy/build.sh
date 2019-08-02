#!/bin/sh

cd ${SRC_DIR}
ls
git submodule init
git submodule update --init --recursive

make all CXX=$CXX
mkdir -p $PREFIX/bin
cp src/tracy $PREFIX/bin
