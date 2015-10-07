#!/bin/bash
set -x
set -e

pushd $SRC_DIR
# Requires libtool and yaggo
autoreconf -i
./configure --prefix=$PREFIX
make
make install
