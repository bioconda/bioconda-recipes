#!/usr/env bash
cd $SRC_DIR
make

mkdir -p $PREFIX/bin
cp $SRC_DIR/bin/* $PREFIX/bin/
chmod u+x $PREFIX/bin/*

