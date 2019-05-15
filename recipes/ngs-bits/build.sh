#!/bin/bash

#link include and lib folders to allow using htslib
ln -s $PREFIX/include htslib/include
ln -s $PREFIX/lib htslib/lib

#build
mkdir build
cd build
echo "QMAKE version..."
qmake --version
echo "cxx ..."
echo $CXX
echo "cxx version..."
$CXX --version
echo "FIXING..."
ln -s $CXX $BUILD_PREFIX/bin/g++
export PATH=$BUILD_PREFIX/bin/:$PATH
echo "QMAKE..."
qmake CONFIG-=debug CONFIG+=release DEFINES+=QT_NO_DEBUG_OUTPUT QMAKE_CXX=${CXX} -Wall -d ../src/tools.pro
echo "MAKE..."
make

#remove test files from bin folder
rm -rf bin/out bin/cpp*-TEST bin/tools-TEST

#deploy (lib)
mkdir -p $PREFIX/lib
mv bin/libcpp* $PREFIX/lib/

#deploy (bin)
mkdir -p $PREFIX/bin
mv bin/* $PREFIX/bin/