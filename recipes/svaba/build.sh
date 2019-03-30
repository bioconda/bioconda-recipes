#!/bin/bash

rm -fr SeqLib
git clone --recursive https://github.com/walaj/SeqLib.git
cd SeqLib
git checkout f7a89a127409a3f52fdf725fa74e5438c68e48fb
git submodule update --recursive
cd ..

export C_INCLUDE_PATH=$PREFIX/include
export LIBRARY_PATH=$PREFIX/lib

./configure CXXFLAGS=-fPIC --prefix=$PREFIX
make
make install
