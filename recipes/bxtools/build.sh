#!/bin/bash
set -eu -o pipefail

rm -rf SeqLib
git clone --recursive https://github.com/walaj/SeqLib
cd SeqLib
git checkout f19055cefcd8f41f13450080bbcf453f692278b2
cd ..

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

./configure --prefix=$PREFIX
make
mkdir -p $PREFIX/bin
cp src/bxtools $PREFIX/bin
