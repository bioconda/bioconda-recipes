#!/bin/sh
make
mkdir -p $PREFIX/bin
mv fasttext $PREFIX/bin
