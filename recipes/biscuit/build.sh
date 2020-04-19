#!/bin/bash

BIN=$PREFIX/bin
mkdir -p $BIN
sed -i.bak 's/CC =/CC ?=/;s/CFLAGS =/CFLAGS ?=/' Makefile
make CC=$CC CFLAGS="$CFLAGS"
cp biscuit $BIN
