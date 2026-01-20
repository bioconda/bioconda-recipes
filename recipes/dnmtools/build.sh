#!/bin/bash

export M4="$BUILD_PREFIX/bin/m4"
autoreconf -if
./configure --prefix="${PREFIX}"

make CXXFLAGS="${CXXFLAGS} -O3 -DNDEBUG -D_LIBCPP_DISABLE_AVAILABILITY" -j"${CPU_COUNT}"
make install
