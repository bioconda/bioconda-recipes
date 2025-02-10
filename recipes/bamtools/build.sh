#!/bin/bash

#sed -i.bak '14i\
#cmake_policy(SET CMP0042 NEW)' CMakeLists.txt
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

# Only build the shared library
#sed -i'.bak' '9,11d' ../src/CMakeLists.txt
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} \
      -DCMAKE_CXX_COMPILER=${CXX} \
      -DCMAKE_INSTALL_INCLUDEDIR=${PREFIX}/include \
      -DCMAKE_INSTALL_LIBDIR=${PREFIX}/lib \
      -DBUILD_SHARED_LIBS=TRUE \
      -DCMAKE_INSTALL_RPATH=${PREFIX}/lib \
      -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=TRUE \
      -DZLIB_ROOT=$PREFIX \
      ..
make install
