#!/bin/bash

./autogen.sh
#./configure CFLAGS="-std=gnu89 -g -O2" --prefix=$PREFIX --datadir=$PREFIX/share
./configure --prefix=$PREFIX --datadir=$PREFIX/share
make -j
make install

mv $PREFIX/share/RNAz/perl/*.pl $PREFIX/bin/.
mv $PREFIX/share/RNAz/perl/RNAz.pm $PREFIX/lib/5.26.2/.
