#!/bin/bash

export CPATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

sed -i.bak 's|tcl/tcl.h|tcl.h|' calcul/CartaGene.h calcul/System.h cgsh/cgsh.cc

rm -rf build
mkdir build
cd build

cmake -DCMAKE_CXX_FLAGS="$CXXFLAGS -DUSE_NEW_CXX" -DCMAKE_INSTALL_PREFIX="$PREFIX/" -DCMAKE_BUILD_TYPE="Release" ..
make -j2
make install
