#!/bin/bash
export CPP_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

# HDF5 doesn't have pkgconfig files yet
export CPPFLAGS="-isystem ${PREFIX}/include"
export LDFLAGS="-L${PREFIX}/lib -lhdf5_cpp -lhdf5"

# configure
# '--wrap-mode nofallback' prevents meson from downloading
# stuff from the internet or using subprojects.
meson \
  --default-library shared \
  --libdir lib \
  --wrap-mode nofallback \
  --prefix "${PREFIX}" \
  -Dtests=false \
  build .

ninja -C build -v
ninja -C build -v install
