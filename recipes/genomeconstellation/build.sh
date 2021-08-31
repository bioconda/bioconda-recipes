#!/bin/bash

mkdir -p $PREFIX/bin

cd src
make CC="$CC" CFLAGS="$CFLAGS $LDFLAGS"
cp jgi_gc $PREFIX/bin
