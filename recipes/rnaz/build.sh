#!/bin/bash
./configure --prefix=$PREFIX --datadir=$PREFIX/share
make
make install
cp $PREFIX/share/RNAz/perl/*.pl $PREFIX
