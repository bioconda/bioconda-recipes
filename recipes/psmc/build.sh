#!/bin/bash

set -xe

export LIBRARY_PATH="$PREFIX/lib"

mkdir -p $PREFIX/bin
make -j"${CPU_COUNT}" CC=$CC CFLAGS="-g -Wall -O2 -I$PREFIX/include -L$PREFIX/lib"
cp psmc $PREFIX/bin
cd utils && make -j"${CPU_COUNT}" CC=$CC CFLAGS="-g -Wall -O2 -I$PREFIX/include -L$PREFIX/lib"
cp * $PREFIX/bin
