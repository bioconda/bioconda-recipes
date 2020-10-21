#!/bin/bash

#link include and lib folders to allow using htslib
ln -s $PREFIX/include htslib/include
ln -s $PREFIX/lib htslib/lib

#qmake bugfix: qmake fails if there is no g++ executable available, even if QMAKE_CXX is explicitly set
ln -s $CXX $BUILD_PREFIX/bin/g++
export PATH=$BUILD_PREFIX/bin/:$PATH

#build (enable debug info by adding '-Wall -d')
mkdir build
cd build
qmake CONFIG-=debug CONFIG+=release DEFINES+=QT_NO_DEBUG_OUTPUT QMAKE_CXX=${CXX} QMAKE_RPATHLINKDIR+=${PREFIX}/lib/ ../src/tools.pro
make
cd ..

#remove test files from bin folder
rm -rf bin/out bin/cpp*-TEST bin/tools-TEST

#deploy (lib)
mkdir -p $PREFIX/lib
mv bin/libcpp* $PREFIX/lib/

#deploy (bin)
mkdir -p $PREFIX/bin
mv bin/* $PREFIX/bin/