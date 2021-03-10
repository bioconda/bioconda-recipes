#!/bin/bash
export LDFLAGS="-lstdc++fs"

mkdir -p $PREFIX/lib
./configure --prefix $PREFIX
make
make install
