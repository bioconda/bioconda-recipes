#!/bin/bash

#strictly use anaconda build environment
export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

export CFLAGS="-I$PREFIX/include -Wall -Wextra -Ofast"
export LDFLAGS="-L$PREFIX/lib"

sed -i.bak "/^PREFIX.*$/d" Makefile
sed -i.bak "/^CFLAGS.*$/d" Makefile

make CC=$CC LIBS="-L${PREFIX}/lib -lm"

mkdir -p "$PREFIX"/bin

cp cgmlst-dists "$PREFIX"/bin/
