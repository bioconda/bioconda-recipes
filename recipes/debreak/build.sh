#!/bin/bash


mkdir -p $PREFIX/bin

wget -O -  https://github.com/ruanjue/bsalign/archive/refs/tags/v1.2.1.tar.gz | tar zxvf -

cd bsalign-1.2.1 && make
chmod +x bsalign
cp bsalign $PREFIX/bin
cd ..
chmod +x debreak
cp debreak *.py $PREFIX/bin
