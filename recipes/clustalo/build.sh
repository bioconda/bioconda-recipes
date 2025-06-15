#!/bin/bash

# use newer config.guess and config.sub that support linux-aarch64
cp -rf ${BUILD_PREFIX}/share/gnuconfig/config.* .
mkdir -p ${PREFIX}/bin

export CPPFLAGS="${CPPFLAGS} -I$PREFIX/include"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib"

if [[ "$(uname)" == "Darwin" ]]; then
    # clang doesn't accept -fopenmp and there's no clear way around that
    ./configure --prefix="${PREFIX}"
else
    ./configure --prefix="${PREFIX}" OPENMP_CFLAGS='-fopenmp' CFLAGS='-DHAVE_OPENMP'
fi
make -j"${CPU_COUNT}"

install -v -m 755 $SRC_DIR/src/clustalo "$PREFIX/bin"
