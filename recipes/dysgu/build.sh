#!/bin/bash
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export C_INCLUDE_PATH=${PREFIX}/include

cd ./dysgu
wget https://github.com/samtools/htslib/releases/download/1.17/htslib-1.17.tar.bz2
tar -xvf htslib-1.17.tar.bz2
rm htslib-1.17.tar.bz2
pwd
ls htslib-1.17
cp -rf htslib-1.17 htslib
rm -rf htslib-1.17
cd ./htslib
pwd
ls
./configure --with-libdeflate
make
cd ../../

$PYTHON setup.py install --single-version-externally-managed --record=record.txt
