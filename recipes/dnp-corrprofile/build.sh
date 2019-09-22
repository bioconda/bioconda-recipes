#!/bin/bash

sed 's/CPROGNAME/corrprofile/g' CMakeLists.template > CMakeLists.txt

mkdir -p  build
cd build

SEQAN_INCLUDE_PATH="$CONDA_DEFAULT_ENV/include/"
CMAKE_PREFIX_PATH="$CONDA_DEFAULT_ENV/share/cmake/seqan"
cmake  ../ -DCMAKE_PREFIX_PATH="$CMAKE_PREFIX_PATH" -DSEQAN_INCLUDE_PATH="$SEQAN_INCLUDE_PATH" 

make
cp corrprofile $PREFIX/bin/dnp-corrprofile
 
