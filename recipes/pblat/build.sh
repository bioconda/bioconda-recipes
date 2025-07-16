#!/bin/bash

make CC=${CC} CFLAGS="-O -Wall -I$PREFIX/include -L$PREFIX/lib -fcommon"

mkdir -p ${PREFIX}/bin
mv pblat ${PREFIX}/bin/pblat

