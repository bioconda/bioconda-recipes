#!/bin/bash

export LD_LIBRARY_PATH=${PREFIX}/lib
export LIBRARY_PATH=${PREFIX}/lib
cmake -H. -Bbuild
ls -l
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} \
      -DCMAKE_CXX_COMPILER=${CXX} \
      -DCMAKE_INSTALL_INCLUDEDIR=${PREFIX}/include \
      -DCMAKE_INSTALL_LIBDIR=${PREFIX}/lib \
      --build build
echo "bin"
ls -l bin
echo "lib"
ls -l lib
"echo build"
ls -l build
