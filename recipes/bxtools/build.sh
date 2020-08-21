#!/bin/bash
set -eu -o pipefail

./configure --prefix=$PREFIX
make AM_MAKEFLAGS=-e
mkdir -p $PREFIX/bin
cp src/bxtools $PREFIX/bin
