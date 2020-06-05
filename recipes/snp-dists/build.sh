#!/bin/bash


#strictly use anaconda build environment
export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

export CFLAGS="-I$PREFIX/include -Wall -Wextra -Ofast -std=c99"
export LDFLAGS="-L$PREFIX/lib"

sed -i.bak "/^PREFIX.*$/d" Makefile
sed -i.bak "/^CFLAGS.*$/d" Makefile

make CC=$CC LIBS="-L${PREFIX}/lib -lz -lm"

mkdir -p "$PREFIX"/bin

cp snp-dists "$PREFIX"/bin/
