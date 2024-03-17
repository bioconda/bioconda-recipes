#!/usr/bin/env bash

export PKG_CONFIG_LIBDIR="${PREFIX}"/lib/pkgconfig

# HDF5 doesn't have pkgconfig files yet
export CPPFLAGS="-isystem ${PREFIX}/include "
export CPPOPTS="-std=c++98"
export LDFLAGS="-L${PREFIX}/lib -lhdf5_cpp -lhdf5"
export LD_LIBRARY_PATH="${PREFIX}/lib"

make -j 8 HDF5INCLUDEDIR=${PREFIX}/include HDF5LIBDIR=${PREFIX}/lib CPPOPTS="-std=c++11" _GLIBCXX_USE_CXX11_ABI=0
cp alignment/bin/blasrmc ${PREFIX}/bin
cp alignment/bin/sawritermc ${PREFIX}/bin
cp alignment/bin/blDotPlot ${PREFIX}/bin
