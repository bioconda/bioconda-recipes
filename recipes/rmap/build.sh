#!/bin/sh

make all
make install

mkdir -p $PREFIX/bin
cp bin/* $PREFIX/bin/
