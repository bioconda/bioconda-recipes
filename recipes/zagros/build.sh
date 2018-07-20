#!/bin/sh

make all
make install

mkdir -p $PREFIX/bin
ls
cp bin/* $PREFIX/bin/
