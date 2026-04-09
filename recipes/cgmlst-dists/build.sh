#!/bin/bash

#strictly use anaconda build environment
export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"

export CFLAGS="${CFLAGS} -I$PREFIX/include -O3 -Wall -Wextra -Ofast -fopenmp"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib"

sed -i.bak "/^PREFIX.*$/d" Makefile
sed -i.bak "/^CFLAGS.*$/d" Makefile

make CC=$CC LIBS="-L${PREFIX}/lib -lm"

mkdir -p "$PREFIX"/bin

install -v -m 0755 cgmlst-dists "$PREFIX/bin"
