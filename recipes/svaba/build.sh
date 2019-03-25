#!/bin/bash
set -eu -o pipefail

rm -rf SeqLib
git clone --recursive https://github.com/walaj/SeqLib
cd SeqLib
git checkout f7a89a127409a3f52fdf725fa74e5438c68e48fb
cd ..

export C_INCLUDE_PATH=$PREFIX/include
export LIBRARY_PATH=$PREFIX/lib

./configure --prefix=$PREFIX
make
make install
