#!/bin/bash
set -eu

mkdir -p $PREFIX/lib
export LIBS="-lstdc++fs -lcurl"

./configure --prefix $PREFIX --with-snappy --with-io_lib
make
make install
