#!/bin/bash


export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

cd $SRC_DIR
make install prefix=$PREFIX/
make test/testLocal
cp bigWig.h $PREFIX/include
cp -r libBigWig.a libBigWig.so $PREFIX/lib
mkdir -p $PREFIX/share/libBigWig
cp -r test $PREFIX/share/libBigWig
./test/testLocal ./test/test.bw >/dev/null
