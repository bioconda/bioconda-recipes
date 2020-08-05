#!/bin/bash

make CC=${CC} CFLAGS="-O -Wall -I$PREFIX/include -L$PREFIX/lib"

mkdir -p ${PREFIX}/bin
mv pblat ${PREFIX}/bin/pblat

