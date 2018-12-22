#!/bin/bash

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include


make zobu="-L${PREFIX}/lib "

mkdir -p $PREFIX/bin
cp bgreat $PREFIX/bin
