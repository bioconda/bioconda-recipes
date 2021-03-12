#!/bin/bash
set -eu

mkdir -p $PREFIX/bin
./configure --prefix=${PREFIX}
make install
