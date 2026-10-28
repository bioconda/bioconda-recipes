#!/bin/bash -euo

set -xe

sed -i.bak "s#CC=.*#CC=$CXX#" Makefile
sed -i.bak "s#CFLAGS=.*#CFLAGS=$CXXFLAGS#" Makefile

make -j"${CPU_COUNT}"

mkdir -p ${PREFIX}/bin
install -v -m 0755 converter neff ${PREFIX}/bin
