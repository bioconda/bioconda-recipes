#!/bin/bash

BIN=$PREFIX/bin
mkdir -p $BIN
make CC="$CC $LDFLAGS" CFLAGS="$CFLAGS"
cp biscuit $BIN
