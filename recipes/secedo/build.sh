#!/bin/bash

if [ -n "${MACOSX_DEPLOYMENT_TARGET}" ]; then
     CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

sed -i.bak '14i\
cmake_policy(SET CMP0042 NEW)' CMakeLists.txt
export LD_LIBRARY_PATH=${PREFIX}/lib
export LIBRARY_PATH=${PREFIX}/lib
mkdir -p build
cd build
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} \
      -DCMAKE_CXX_COMPILER=${CXX} \
      -DCMAKE_INSTALL_INCLUDEDIR=${PREFIX}/include \
      -DCMAKE_INSTALL_LIBDIR=${PREFIX}/lib \
      -DZLIB_ROOT=$PREFIX \
      ${EXTRA_PARAMS} \
      ..
make install
