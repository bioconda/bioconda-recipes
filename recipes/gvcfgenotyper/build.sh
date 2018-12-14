#!/bin/bash
set -eu -o pipefail

cd external/htslib-*
./configure --prefix=${PREFIX} --disable-lzma --disable-bz2
cd ../..
sed -i.bak 's^-Isrc/c/^-Isrc/c/ -I${PREFIX}/include^' Makefile
sed -i.bak 's^-lpthread^-lpthread -L$(PREFIX)/lib^' Makefile
make
mkdir -p $PREFIX/bin
cp bin/gvcfgenotyper $PREFIX/bin
