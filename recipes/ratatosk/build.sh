#!/bin/bash
set -x

git clone https://github.com/pmelsted/bifrost.git
cd bifrost
git checkout 9e6f948ce2c27de32bc687502e777aebc9eab53d
cd ..
mv bifrost/* Bifrost/.

mkdir -p $PREFIX/bin
mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=$PREFIX ..
make
make install