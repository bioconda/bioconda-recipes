#!/bin/bash


#strictly use anaconda build environment
export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

export CFLAGS="-I$PREFIX/include -Wall -Wextra -O3 -std=c99"
export LDFLAGS="-L$PREFIX/lib"

sed -i.bak "/^PREFIX.*$/d" Makefile
sed -i.bak "/^CFLAGS.*$/d" Makefile

make

mkdir -p "$PREFIX"/bin

cp snp-dists "$PREFIX"/bin/
