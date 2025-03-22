#!/bin/bash

mkdir -p $PREFIX/bin

make -f Makefile.conda CFLAGS="${CFLAGS} -I${PREFIX}/include -L${PREFIX}/lib" opt_lib=${PREFIX}/lib portable=1
