#!/bin/bash

mkdir build
cd build
# Ensure installed binaries can find shared libs in conda-style prefixes without requiring LD_LIBRARY_PATH.
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} \
	-DCMAKE_INSTALL_RPATH="${PREFIX}/lib;${PREFIX}/lib.AVX2_256;" \
	-DCMAKE_BUILD_WITH_INSTALL_RPATH=OFF \
	-DCMAKE_INSTALL_RPATH_USE_LINK_PATH=OFF \
	..
make
# make check
make install
mv ${PREFIX}/chap/bin/* ${PREFIX}/bin
