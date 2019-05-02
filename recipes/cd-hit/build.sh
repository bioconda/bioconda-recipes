#!/bin/sh

export CFLAGS="-I$PREFIX/include"
export CPPFLAGS="-I$PREFIX/include"
export CXXFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

sed -i.bak 's/^CC =$//g' Makefile
sed -i.bak 's/^#LDFLAGS.*//g' Makefile


if [[ "$OSTYPE" == "darwin"* ]]; then
  #forced disabling of openmp for macos
  make CC=$GXX
else
  make CC=$GXX
fi

mkdir -p $PREFIX/bin 
make install PREFIX=$PREFIX/bin 
