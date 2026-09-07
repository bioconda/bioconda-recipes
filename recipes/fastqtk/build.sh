#!/bin/bash

mkdir -p "${PREFIX}/bin"

export CFLAGS="$CFLAGS -O3 -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

make clean

sed -i.bak 's|-march=native||' Makefile
rm -f *.bak

if [[ "$(uname -s)" == "Darwin" ]]; then
	# clang++ is required for OSX build
	make CC="${CXX}"
else
	make CC="${CC}"
fi

install -v -m 0755 fastqtk "${PREFIX}/bin"
