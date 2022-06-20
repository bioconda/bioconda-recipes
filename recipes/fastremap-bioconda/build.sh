#!/bin/bash

mkdir -p $PREFIX/bin

export CPATH=${PREFIX}/include

cd zlib && ./configure && make && cd ..

make CC=$CC EXECUTABLE="$PREFIX/bin/FastRemap"
