#!/bin/bash

mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/lib"
mkdir -p "${PREFIX}/include"

# Needed for building utils dependency
export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -pthread -lrt -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"

# Not the most elegant way to do this, but it seems to get it to build
mkdir -p build
cd build || exit 1

if [[ `uname` == "Darwin" ]]; then
    cmake -DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}" ..
else
    cmake -DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}" \
        -DCMAKE_C_STANDARD_LIBRARIES="-lrt" \
        ..
fi

make CC="${CC}" CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" utils
make CC="${CC}" CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" sgsl
make CC="${CC}" CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" htslib

cd ../
cmake --build build --target install

# Needed to run asset builder
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${PREFIX}/bin/build_biscuit_QC_assets.pl
