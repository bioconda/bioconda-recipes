#!/bin/bash

export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

export LDFLAGS="${LDFLAGS} -Wl,-headerpad_max_install_names"

# Build ntSynt
mkdir -p ${PREFIX}/bin
meson setup build --prefix ${PREFIX}
cd build
ninja install
