#!/usr/bin/env bash

set -xe

cd ./src/

CC="${CC}" CXX="${CXX}" CC_FLAGS="${CFLAGS} -D_LIBCPP_ENABLE_CXX17_REMOVED_AUTO_PTR" make -j"${CPU_COUNT}"

mkdir -p $PREFIX/bin
install -m 755 ghostx $PREFIX/bin
