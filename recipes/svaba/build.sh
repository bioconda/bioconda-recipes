#!/bin/bash
set -eu -o pipefail

rm -rf SeqLib
git clone --recursive https://github.com/walaj/SeqLib
cd SeqLib
git checkout 770cd10c308430e1719d54ebedcfe708db560bec
cd ..

export C_INCLUDE_PATH=$PREFIX/include
export LIBRARY_PATH=$PREFIX/lib

./configure --prefix=$PREFIX
make
make install
