#!/bin/bash

set -xe

mkdir -p $PREFIX/bin

export C_INCLUDE_PATH="${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

make -j ${CPU_COUNT} CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}" CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}"
cp minigraph $PREFIX/bin
