#!/bin/sh

export CFLAGS="-I$PREFIX/include"
export CPPFLAGS="-I$PREFIX/include"
export CXXFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

sed -i.bak 's/^CC =$//g' Makefile
sed -i.bak 's/^#LDFLAGS.*//g' Makefile


if [[ "$OSTYPE" == "darwin"* ]]; then
  export C_INCLUDE_PATH=${C_INCLUDE_PATH}:${PREFIX}/include
  make 
else
  make CC=$GXX
fi

mkdir -p $PREFIX/bin 
make install PREFIX=$PREFIX/bin 
