#!/bin/bash

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

mkdir -p $PREFIX/bin

./configure --prefix=$PREFIX
make
make install

for platform in illumina 454 SOLiD;
do
    cp art_${platform} $PREFIX/bin/
done
