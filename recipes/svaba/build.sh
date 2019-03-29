#!/bin/bash

rm -fr SeqLib
git clone --recursive https://github.com/walaj/SeqLib.git
cd SeqLib
git checkout d12cf224f7a488b913eabbcf54a215e17238032c
git submodule update --recursive
cd ..

./configure --prefix=$PREFIX
make
make install
