#!/bin/bash -euo
set -xe

mkdir -p "${PREFIX}/bin"

sed -i.bak "s#CC=.*#CC=$CXX#" Makefile
sed -i.bak "s#CFLAGS=.*#CFLAGS=$CXXFLAGS -D_LIBCPP_DISABLE_AVAILABILITY#" Makefile
rm -f *.bak

make -j"${CPU_COUNT}"

install -v -m 0755 converter neff "${PREFIX}/bin"
