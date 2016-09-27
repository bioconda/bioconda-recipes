#!/bin/bash

mkdir -p $PREFIX/bin

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
autoreconf -i
./configure --prefix=$PREFIX/bin
make
make install
cd python
python setup.py install
