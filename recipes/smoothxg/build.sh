#!/bin/bash
export LIBRARY_PATH=${PREFIX}/lib
export LD_LIBRARY_PATH=${PREFIX}/lib
export CPATH=${PREFIX}/include
export C_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
sed -i 's/-msse4.1/-march=sandybridge -Ofast/g' deps/spoa/CMakeLists.txt
sed -i 's/-march=native/-march=sandybridge -Ofast/g' deps/spoa/CMakeLists.txt
sed -i 's/-march=native/-march=sandybridge -Ofast/g' deps/abPOA/CMakeLists.txt
cmake -H. -Bbuild -DCMAKE_BUILD_TYPE=Generic -DEXTRA_FLAGS='-march=sandybridge -Ofast'
cmake --build build --verbose
mkdir -p $PREFIX/bin
mv bin/* $PREFIX/bin
