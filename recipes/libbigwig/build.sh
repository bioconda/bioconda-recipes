#!/bin/bash


export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
export LD_LIBRARY_PATH=${PREFIX}/lib

cd $SRC_DIR
make install prefix=$PREFIX/
make test/testLocal
cp bigWig.h $PREFIX/include
cp -r libBigWig.a libBigWig.so $PREFIX/lib
mkdir -p $PREFIX/share/libBigWig
cp -r test $PREFIX/share/libBigWig
./test/testLocal ./test/test.bw >/dev/null
