#!/usr/bin/env bash

set -x -e

pushd $SRC_DIR

autoreconf -fi -Im4
./configure --prefix=$PREFIX
make
make install
