#!/bin/bash
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

mkdir -p $PREFIX/bin

make
make install prefix=$PREFIX

cp centrifuge-kreport $PREFIX/bin
cp evaluation/{centrifuge_evaluate.py,centrifuge_simulate_reads.py} $PREFIX/bin
