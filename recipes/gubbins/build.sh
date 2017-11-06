#!/bin/bash
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

autoreconf -i
./configure --prefix=$PREFIX
make
make install
cd python
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
