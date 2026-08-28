#!/bin/bash

export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

unset MACOSX_DEPLOYMENT_TARGET  # avoid meson re-adding a conflicting -mmacosx-version-min

# Build ntSynt
mkdir -p ${PREFIX}/bin
meson setup build --prefix ${PREFIX}  \
	 --buildtype=release \
 	 --default-library=shared
cd build
ninja install
