#!/bin/bash
export LIBRARY_PATH=${PREFIX}/lib
export LD_LIBRARY_PATH=${PREFIX}/lib
export CPATH=${PREFIX}/include
export C_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
sed -i 's/-march=native/-march=haswell/g' deps/spoa/CMakeLists.txt
sed -i 's/-march=native/-march=haswell/g' deps/abPOA/CMakeLists.txt
cmake -H. -Bbuild -DCMAKE_BUILD_TYPE=Generic
cmake --build build
mkdir -p $PREFIX/bin
mv bin/* $PREFIX/bin
