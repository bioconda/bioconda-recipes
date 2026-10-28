#!/bin/bash

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p "$PREFIX/bin"

cd src

make CC="${CC}" CXX="${CXX}" INCLUDES="-I${PREFIX}/include -I./include -I./include/ncbi-blast+" -j"${CPU_COUNT}"

cd $SRC_DIR/bin

install -v -m 0755 kaiju* "${PREFIX}/bin"
