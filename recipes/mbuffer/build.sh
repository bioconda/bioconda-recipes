#!/bin/bash
set -eu -o pipefail
cp -rf $BUILD_PREFIX/share/gnuconfig/config.* .
./configure --prefix=$PREFIX
make
make install
