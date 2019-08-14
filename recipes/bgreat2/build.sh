#!/bin/bash

export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export CPATH=${PREFIX}/include


make zobu="$LDFLAGS" CC=$CXX CFLAGS="$CXXFLAGS -flto -funit-at-a-time -fopenmp -lz"

mkdir -p $PREFIX/bin
cp bgreat $PREFIX/bin
