#!/bin/bash

set -x -e

mkdir -p $PREFIX/bin

./configure --prefix=$PREFIX/bin --disable-openmp
make clean
make
make install
