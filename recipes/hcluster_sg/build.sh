#!/bin/sh
set -e

make CXX="${CXX}" CFLAGS="${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}"
mkdir -p "$PREFIX/bin"
cp hcluster_sg "$PREFIX/bin/"
