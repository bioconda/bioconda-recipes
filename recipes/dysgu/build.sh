#!/bin/bash
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export C_INCLUDE_PATH=${PREFIX}/include

cd ./dysgu
wget -O htslib.tar.bz2 https://github.com/samtools/htslib/releases/download/1.17/htslib-1.17.tar.bz2
tar -xvf htslib.tar.bz2
mv ./htslib-1.17 ./htslib
rm htslib.tar.bz2
cd ./htslib
pwd
ls
./configure --with-libdeflate
make
cd ../../

$PYTHON setup.py install --single-version-externally-managed --record=record.txt
