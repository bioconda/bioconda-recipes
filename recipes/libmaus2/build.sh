#!/bin/bash
export LDFLAGS="-lstdc++fs"

mkdir -p $PREFIX/lib
./configure
make
find . -name *.so
find . -name *.a
mv libmaus2.so $PREFIX/lib
