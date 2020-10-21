#! /bin/bash
export C_INCLUDE_PATH=$C_INCLUDE_PATH:${PREFIX}/include
#export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:${PREFIX}/include
export LIBRARY_PATH=$LIBRARY_PATH:${PREFIX}/lib

rm -fr build
mkdir -p build
cd build
cmake ../src
make -j8
mkdir -p ${PREFIX}/bin
mv smashpp ${PREFIX}/bin
