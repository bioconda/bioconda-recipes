#!/bin/sh

export CFLAGS="-I$PREFIX/include"
export CPPFLAGS="-I$PREFIX/include"
export CXXFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

sed -i.bak 's/^CC =$//g' Makefile
sed -i.bak 's/^#LDFLAGS.*//g' Makefile


if [[ "$OSTYPE" == "darwin"* ]]; then
  CCFLAGS="$CCFLAGS -Wl,-rpath ${PREFIX}/lib -L${PREFIX}/lib -I${PREFIX}/include -fopenmp"
	LDFLAGS="$LDFLAGS -stdlib=libc++"
  sed -i.bak 's/CCFLAGS = -fopenmp/CCFLAGS += -fopenmp/g' Makefile
  make CC=clang++
else
  make CC=$GXX
fi

mkdir -p $PREFIX/bin 
make install PREFIX=$PREFIX/bin 
