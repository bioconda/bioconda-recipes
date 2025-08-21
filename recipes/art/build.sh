#!/bin/bash

set -xe

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

mkdir -p $PREFIX/bin

if [[ "$HOST" == "arm64-apple-"* ]]; then
    ./configure --prefix=$PREFIX --host=arm
else
    ./configure --prefix=$PREFIX
fi
make -j ${CPU_COUNT}
make install

for platform in illumina 454 SOLiD;
do
    cp art_${platform} $PREFIX/bin/
done
