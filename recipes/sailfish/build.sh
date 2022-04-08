#!/bin/bash

# try to avoid nameclash with jemalloc due to
# 
export CFLAGS="${CFLAGS} -DJEMALLOC_JET"

mkdir -p build
cd build
cmake \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DBOOST_ROOT="${PREFIX}" \
    -DBoost_NO_SYSTEM_PATHS=ON \
    -DBoost_DEBUG=ON \
    -DBUILD_SHARED_LIBS=ON \
    ..
make install
