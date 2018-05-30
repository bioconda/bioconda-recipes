#!/bin/bash
make
mkdir -p $PREFIX/bin
cp -p $SRC_DIR/flash $PREFIX/bin/
