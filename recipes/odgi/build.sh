#!/bin/bash
git submodule update --init --recursive
export LD_LIBRARY_PATH=${PREFIX}/lib
export LIBRARY_PATH=${PREFIX}/lib
export LD_LIBRARY_PATH=${PREFIX}/lib
export C_INCLUDE_PATH=${PREFIX}/include
cmake -H. -Bbuild
ls -l
#cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} \
#      -DCMAKE_CXX_COMPILER=${CXX} \
#      -DCMAKE_INSTALL_INCLUDEDIR=${PREFIX}/include \
#      -DCMAKE_INSTALL_LIBDIR=${PREFIX}/lib \
#      --build build
cmake --build build
echo "bin"
ls -l bin
echo "lib"
ls -l lib
echo "build"
ls -l build
