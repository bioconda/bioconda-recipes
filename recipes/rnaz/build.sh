#!/bin/bash
./configure --prefix=$PREFIX/RNAz --datadir=$PREFIX/RNAz/share
make
make install
mkdir -p $PREFIX/bin
cp $PREFIX/RNAz/bin/RNAz $PREFIX/bin
