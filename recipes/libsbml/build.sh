#!/bin/bash
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} \
      -DCMAKE_INSTALL_LIBDIR=${PREFIX}/lib \
      -DCMAKE_CXX_COMPILER=${CXX} \
      -DCMAKE_C_COMPILER=${CC} \
      -DWITH_SWIG=OFF \
      -DLIBSBML_DEPENDENCY_DIR="${PREFIX}" \
      -DLIBXML_INCLUDE_DIR=${PREFIX}/include/libxml2 \
      ..
make -j"${CPU_COUNT}"
make install
