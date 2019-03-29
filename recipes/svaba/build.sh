#!/bin/bash

rm -fr SeqLib
git clone --recursive https://github.com/walaj/SeqLib.git
cd SeqLib
git checkout f7a89a127409a3f52fdf725fa74e5438c68e48fb
git submodule update --recursive
cd ..

./configure --prefix=$PREFIX
make
make install
