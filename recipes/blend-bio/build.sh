#!/bin/bash
mkdir -p $PREFIX/bin

export CPATH=${PREFIX}/include

make -c $PREFIX/src INCLUDES="-I$PREFIX/include"
mv $PREFIX/src/blend $PREFIX/bin
