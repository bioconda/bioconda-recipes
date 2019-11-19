#!/bin/bash

export LD_LIBRARY_PATH=${PREFIX}/lib
export LIBRARY_PATH=${PREFIX}/lib
mkdir -p build
cd build
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} \
      -DCMAKE_CXX_COMPILER=${CXX} \
      -DCMAKE_INSTALL_INCLUDEDIR=${PREFIX}/include \
      -DCMAKE_INSTALL_LIBDIR=${PREFIX}/lib \
      -DZLIB_ROOT=$PREFIX \
      ..
make install