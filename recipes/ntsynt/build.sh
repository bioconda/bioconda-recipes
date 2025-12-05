#!/bin/bash

export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

# Build ntSynt
mkdir -p ${PREFIX}/bin
meson setup build --prefix ${PREFIX}  \
	 --buildtype=release \
 	 --default-library=shared
cd build
ninja install
