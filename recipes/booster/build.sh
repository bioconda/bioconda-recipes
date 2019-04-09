#!/bin/bash

cd $SRC_DIR/src
make CC=$CC

mkdir -p $PREFIX/bin
cp booster $PREFIX/bin

