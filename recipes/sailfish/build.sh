#!/bin/bash

# try to avoid nameclash with jemalloc due to
# 
export CFLAGS="${CFLAGS} -DJEMALLOC_JET"

find $PREFIX -name "libtbb*" -print
mkdir -p build
cd build
cmake \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DTBB_LIB_DIR="${PREFIX}/lib" \
    -DTBB_INCLUDE_DIR="${PREFIX}/include/openapi" \
    -DBOOST_ROOT="${PREFIX}" \
    -DBoost_NO_SYSTEM_PATHS=ON \
    -DBoost_DEBUG=ON \
    -DBUILD_SHARED_LIBS=ON \
    ..
make install
