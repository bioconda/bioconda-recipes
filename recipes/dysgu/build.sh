#!/bin/bash
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export C_INCLUDE_PATH=${PREFIX}/include

cd ./dysgu
git clone --recurse-submodules https://github.com/samtools/htslib.git
cd ./htslib
autoreconf -i
./configure --with-libdeflate
make
cd ../../

$PYTHON setup.py install --single-version-externally-managed --record=record.txt
