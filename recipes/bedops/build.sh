#!/bin/bash
set -eu -o pipefail

mkdir -p $PREFIX/bin

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* .

make all CC=$CC CXX=$CXX SFLAGS= -j"${CPU_COUNT}"
make install_all

install -v -m 0755 bin/* $PREFIX/bin
