#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

#make -j8 INCLUDES="-I$PREFIX/include" CFLAGS="-L$PREFIX/lib"
make CFLAGS="${CFLAGS} -fcommon" CC=$CC

cd misc

#make -j8 INCLUDES="-I$PREFIX/include -I../" CFLAGS="-L$PREFIX/lib"
make CFLAGS="${CFLAGS} -fcommon" CC=$CC

cd ..

mkdir -p $PREFIX/bin

cp gfaview $PREFIX/bin/
cp misc/falcon2gfa $PREFIX/bin/
cp misc/fastg2gfa $PREFIX/bin/
cp misc/mag2gfa $PREFIX/bin/
cp misc/supernova2gfa $PREFIX/bin/
