#!/bin/bash
set -ex

mkdir -p build && cd build
cmake \
    -DCMAKE_PREFIX_PATH=${PREFIX} \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS} \
    -D__STDC_FORMAT_MACROS" \
    -DEGL_INCLUDE_DIR:PATH=${BUILD_PREFIX}/${HOST}/sysroot/usr/include \
    -DEGL_LIBRARY:FILEPATH=${BUILD_PREFIX}/${HOST}/sysroot/usr/lib/libEGL.so.1 \
    -DOPENGL_egl_LIBRARY:FILEPATH=${BUILD_PREFIX}/${HOST}/sysroot/usr/lib/libEGL.so.1 \
    -DEGL_opengl_LIBRARY:FILEPATH=${BUILD_PREFIX}/${HOST}/sysroot/usr/lib64/libGL.so \
    -DOPENGL_opengl_LIBRARY:FILEPATH=${BUILD_PREFIX}/${HOST}/sysroot/usr/lib64/libGL.so \
    ..
make

# Install
mkdir -p $PREFIX/bin
cp BandageNG $PREFIX/bin/Bandage
