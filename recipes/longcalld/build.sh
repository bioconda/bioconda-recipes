#!/bin/bash

mkdir -p $PREFIX/bin

make CFLAGS="${CFLAGS} -I${PREFIX}/include -L${PREFIX}/lib"
