#!/bin/bash
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

mkdir -p $PREFIX/bin
sed -i -e 's/-march=native/-msse4.2 -mpopcnt/g' Makefile
make
make install PREFIX=$PREFIX

