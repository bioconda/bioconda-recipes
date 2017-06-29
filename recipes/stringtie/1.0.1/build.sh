#!/bin/sh

sed -i 's/^LIBS.*/LIBS := -lbam -lz/g' Makefile

make release
mkdir -p $PREFIX/bin
mv stringtie $PREFIX/bin
