#!/bin/bash

set -xe

export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

mkdir -p $PREFIX/bin

sed "/^GCC/d;/^CC =/d;/^CPP =/d;/^CXX =/d" < Makefile > Makefile.new
mv Makefile.new Makefile
cat Makefile
make -j"${CPU_COUNT}" CC=$CC CXX=$CXX RELEASE_FLAGS="$CXXFLAGS"
make install prefix=$PREFIX

