#!/bin/bash

mkdir -p $PREFIX/bin

./autogen.sh
./configure --prefix=$PREFIX --with-sparsehash=$PREFIX
make
make install
