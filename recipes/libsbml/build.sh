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
      -DENABLE_COMP=ON \
      -DENABLE_FBC=ON \
      -DENABLE_GROUPS=ON \
      -DENABLE_L3V2EXTENDEDMATH=ON \
      -DENABLE_LAYOUT=ON \
      -DENABLE_MULTI=ON \
      -DENABLE_QUAL=ON \
      -DENABLE_RENDER=ON \
      ..
make -j"${CPU_COUNT}"
make install
