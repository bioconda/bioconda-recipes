#!/bin/bash
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

mkdir -p $PREFIX/bin

make CC=$CC CXX=$CXX RELEASE_FLAGS="$CXXFLAGS"
make install prefix=$PREFIX

