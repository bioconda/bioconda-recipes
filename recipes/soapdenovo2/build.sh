#!/bin/sh

set -x -e

mkdir -p $PREFIX/bin

make prefix=$PREFIX
make install
