#!/bin/bash
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export C_INCLUDE_PATH=${PREFIX}/include

# build bundled htslib
cd ./dysgu/htslib
autoreconf -i
./configure
make
cd ../../

$PYTHON setup.py install --single-version-externally-managed --record=record.txt
