#!/bin/bash

mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DHAVE_TESTS=0 -DHAVE_MPI=0 -DHAVE_SSE4_1=1 -DVERSION_OVERRIDE="${PKG_VERSION}" ..
make -j${CPU_COUNT} ${VERBOSE_CM}
make install
