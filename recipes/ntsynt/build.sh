#!/bin/bash

export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

# Build ntSynt
mkdir -p ${PREFIX}/bin
meson setup build --prefix ${PREFIX}
cd build
ninja install
