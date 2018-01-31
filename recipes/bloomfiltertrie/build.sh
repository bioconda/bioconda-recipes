#!/bin/bash

set -x -e

mkdir -p $PREFIX/bin

./configure --prefix=$PREFIX/bin
make clean
make
make install
