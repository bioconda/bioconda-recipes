#!/bin/bash
export LIBRARY_PATH=${PREFIX}/lib
export LD_LIBRARY_PATH=${PREFIX}/lib
export CPATH=${PREFIX}/include
export C_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
sed -i 's/-march=native/-march=sandybridge/g' src/common/wflign/deps/WFA2-lib/Makefile
cmake -H. -Bbuild -DCMAKE_BUILD_TYPE=Generic -DEXTRA_FLAGS='-march=sandybridge -Ofast'
cmake --build build
mkdir -p $PREFIX/bin
mv build/bin/* $PREFIX/bin
mv scripts/split_approx_mappings_in_chunks.py $PREFIX/bin
