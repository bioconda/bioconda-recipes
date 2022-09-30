#!/bin/bash


export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
export LD_LIBRARY_PATH=${PREFIX}/lib

CFLAGS="$CFLAGS -g -Wall -O3 -Wsign-compare -L$PREFIX/lib -I$PREFIX/include"
LIBS="$LDFLAGS -L$PREFIX/lib -lcurl -lm -lz"

sed -i.bak "s/--suffix=.c/foo/" Makefile
make install prefix=$PREFIX/ CC=$CC CFLAGS="$CFLAGS" LIBS="$LIBS"
make test/testLocal CC=$CC CFLAGS="$CFLAGS" LIBS="$LIBS"
cp bigWig.h $PREFIX/include
cp -r libBigWig.a libBigWig.so $PREFIX/lib
mkdir -p $PREFIX/share/libBigWig
cp -r test $PREFIX/share/libBigWig
./test/testLocal ./test/test.bw >/dev/null
