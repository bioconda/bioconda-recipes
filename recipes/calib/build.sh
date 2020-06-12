#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
export CPATH=${PREFIX}/include

make
mkdir -p ${PREFIX}/bin
cp -f calib ${PREFIX}/bin
calib --help

mkdir consensus/spoa_v1.1.3/build
cd consensus/spoa_v1.1.3/build
cmake -DCMAKE_BUILD_TYPE=Release ..
make
cd ../..
g++ calib_cons.cc -std=c++11 -O3 -pthread -Ispoa_v1.1.3/include/ -Lspoa_v1.1.3/build/lib/ -lspoa -o calib_cons
cp -f calib_cons ${PREFIX}/bin
calib_cons --help
