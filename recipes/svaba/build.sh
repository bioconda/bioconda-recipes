#!/bin/bash

cd ..

rm -fr /opt/conda/conda-bld/svaba_1553545215578/work
git clone --recursive https://github.com/walaj/svaba.git work

cd work

git checkout 1.1.0
git submodule update --recursive

export C_INCLUDE_PATH=$PREFIX/include
export LIBRARY_PATH=$PREFIX/lib

./configure --prefix=$PREFIX
make
make install
