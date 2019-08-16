#!/bin/bash
set -eu -o pipefail

./configure

sed -i 's/CC = gcc/compiler = ${CC}/g' Makefile
sed -i 's/$(CC)/$(compiler)/g' Makefile

make CC=${CC} CXX=${CXX} CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}"
make install

mkdir -p ${PREFIX}/bin
cp bin/svaba ${PREFIX}/bin/
