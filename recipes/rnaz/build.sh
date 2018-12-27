#!/bin/bash
./configure --prefix=$PREFIX --datadir=$PREFIX/share
make
make install
mv $PREFIX/bin/RNAz.pm $PREFIX/lib/perl5/site_perl/*/.
