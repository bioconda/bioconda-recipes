#!/bin/bash

BIN=$PREFIX/bin
mkdir -p $BIN
cat Makefile
make CC=$CC CFLAGS="$CFLAGS"
cp biscuit $BIN
