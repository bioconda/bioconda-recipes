#!/bin/bash

mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/lib"
mkdir -p "${PREFIX}/include"

# Needed for building utils dependency
export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -pthread -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"

mkdir -p build
cd build || exit 1
cmake -DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}" ..
#make CC="${CC}" CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}"
make CC="${CC}" CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" install

# Needed to run asset builder
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${PREFIX}/bin/build_biscuit_QC_assets.pl
