#!/bin/bash

mkdir -p $PREFIX/bin

export CPATH=${PREFIX}/include

make EXECUTABLE="$PREFIX/bin/FastRemap" INCLUDES="-I$PREFIX/include" CFLAGS="-c -O3 -std=c++2a -pthread -O3 -DNDEBUG -DSEQAN_HAS_ZLIB=1 -DSEQAN_DISABLE_VERSION_CHECK=YES -W -Wall -pedantic -L$PREFIX/lib"

