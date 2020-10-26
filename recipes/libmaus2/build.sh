#!/bin/bash
export LDFLAGS="-lstdc++fs"

mkdir -p $PREFIX/lib
./configure
make
ls
find . -name *.h -print
cp ./src/.libs/*.so $PREFIX/lib
cp ./src/.libs/*.a $PREFIX/lib
