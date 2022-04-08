#!/usr/bin/env bash

cd $SRC_DIR
make bin/MBG
mkdir -p $PREFIX/bin
cp bin/MBG $PREFIX/bin
