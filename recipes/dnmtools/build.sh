#!/bin/bash

autoreconf -if
./configure --prefix="${PREFIX}"

make CXXFLAGS="${CXXFLAGS} -O3 -DNDEBUG -D_LIBCPP_DISABLE_AVAILABILITY" -j"${CPU_COUNT}"
make install
