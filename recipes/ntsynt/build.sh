#!/bin/bash

export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

unset MACOSX_DEPLOYMENT_TARGET  # avoid meson re-adding a conflicting -mmacosx-version-min

echo "=== DEBUG: incoming flags ==="
echo "CXXFLAGS=$CXXFLAGS"
echo "CFLAGS=$CFLAGS"
echo "LDFLAGS=$LDFLAGS"
echo "MACOSX_DEPLOYMENT_TARGET=$MACOSX_DEPLOYMENT_TARGET"
echo "=============================="

# Build ntSynt
mkdir -p ${PREFIX}/bin
meson setup build --prefix ${PREFIX}  \
	 --buildtype=release \
 	 --default-library=shared
cd build
ninja install
