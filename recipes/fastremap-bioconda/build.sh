#!/bin/bash

mkdir -p $PREFIX/bin

export CPATH=${PREFIX}/include
export CFLAGS="-c -O3 -std=c++2a -pthread -DNDEBUG -DSEQAN_HAS_ZLIB=1 -DSEQAN_DISABLE_VERSION_CHECK=YES -I$PREFIX/include -L$PREFIX/lib"
export LDFLAGS="$LDFLAGS -lz -lpthread -L$PREFIX/lib"

make CC=$CC EXECUTABLE="$PREFIX/bin/FastRemap" LDFLAGS=$LDFLAGS INCLUDES="-I$PREFIX/include" CFLAGS=$CFLAGS
