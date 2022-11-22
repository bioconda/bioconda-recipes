#!/bin/bash
mkdir -p $PREFIX/bin

export CPATH=${PREFIX}/include

make -C $PREFIX/src INCLUDES="-I$PREFIX/include"
mv $PREFIX/src/blend $PREFIX/bin
