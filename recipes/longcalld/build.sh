#!/bin/bash


mkdir -p $PREFIX/bin

export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

make CFLAGS="${CFLAGS} -I${PREFIX}/include" LIB_PATH="-L${PREFIX}/lib"
