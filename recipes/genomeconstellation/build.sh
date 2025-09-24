#!/bin/bash

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/include
if [[ $(uname -m) == 'aarch64' ]]; then

git clone https://github.com/DLTcollab/sse2neon.git
cp sse2neon/sse2neon.h $PREFIX/include 
fi
cd src
make CC="$CC" CFLAGS="$CFLAGS $LDFLAGS"
cp jgi_gc $PREFIX/bin
