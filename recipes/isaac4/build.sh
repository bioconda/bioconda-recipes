#!/bin/sh

mkdir build
cd build
../src/configure --prefix=${PREFIX}
make
make install
