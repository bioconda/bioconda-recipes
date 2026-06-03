#!/usr/bin/env bash

set -xe

wget https://github.com/simd-everywhere/simde/archive/refs/tags/v0.8.2.tar.gz
tar zxvf v0.8.2.tar.gz

export CFLAGS="${CFLAGS} -I ${SRC_DIR}/simde-0.8.2/simde -Wall -O2 -DDYNAMIC_ZLIB"
export CXXFLAGS="${CXXFLAGS} -I ${SRC_DIR}/simde-0.8.2/simde -Wall -O2"
export LDFLAGS="${LDFLAGS} -lopenblas -lpthread -ldl"

echo Building ... 
make -j CFLAGS="${CFLAGS}" DESTDIR="${PREFIX}" PREFIX="" CC="${CC}" CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" ZLIB="-lz" LDFLAGS="${LDFLAGS}" BLASFLAGS=""

echo Installing
make install DESTDIR="${PREFIX}" PREFIX="" 
