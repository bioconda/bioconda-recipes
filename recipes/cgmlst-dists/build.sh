#!/bin/bash

#strictly use anaconda build environment
export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

export CFLAGS="-I$PREFIX/include -O3 -Wall -Wextra -Ofast"
export LDFLAGS="-L$PREFIX/lib -lomp"

sed -i.bak "/^PREFIX.*$/d" Makefile
sed -i.bak "/^CFLAGS.*$/d" Makefile

make CC=$CC LIBS="-L${PREFIX}/lib -lm -lomp"

mkdir -p "$PREFIX"/bin

cp cgmlst-dists "$PREFIX"/bin/
