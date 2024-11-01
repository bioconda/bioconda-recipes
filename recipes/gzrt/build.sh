#!/bin/bash

# Automatically download https://www.urbanophile.com/arenn/hacking/gzrt/gzrt-0.8.tar.gz, unpack, and cd into the unpacked folder

export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

make
chmod +x gzrecover

mkdir -p $PREFIX/bin
cp gzrecover $PREFIX/bin
