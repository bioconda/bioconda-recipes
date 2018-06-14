#!/usr/bin/env bash

set -x -e

pushd $SRC_DIR

autoreconf -i
./configure --prefix=$PREFIX
make
make install
