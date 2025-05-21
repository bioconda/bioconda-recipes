#!/bin/bash

export M4="${BUILD_PREFIX}/bin/m4"

autoreconf -if
./configure --prefix="$PREFIX"

make CXXFLAGS="${CXXFLAGS} -O3 -D_LIBCPP_DISABLE_AVAILABILITY"
make install
