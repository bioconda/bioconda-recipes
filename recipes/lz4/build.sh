#!/bin/sh

mkdir -p $PREFIX/bin

make prefix=$PREFIX 
make prefix=$PREFIX install
