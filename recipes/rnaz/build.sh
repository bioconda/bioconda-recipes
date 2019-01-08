#!/bin/bash

./configure CFLAGS="-std=gnu89 -g -O2" --prefix=$PREFIX --datadir=$PREFIX/share
make
make install

cp $PREFIX/share/RNAz/perl/*.pl $PREFIX/bin/.
cp $PREFIX/share/RNAz/perl/RNAz.pm $PREFIX/lib/5.26.2/.
