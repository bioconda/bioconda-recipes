#!/bin/bash

autoreconf -if
./configure --prefix="$PREFIX"

make CXXFLAGS="${CXXFLAGS} -O3 -D_LIBCPP_DISABLE_AVAILABILITY"
make install
