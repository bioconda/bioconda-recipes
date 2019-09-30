#!/bin/bash

./autogen.sh
./configure --prefix=$PREFIX --datadir=$PREFIX/share CFLAGS="$CFLAGS"
make -j
make install

mv $PREFIX/share/RNAz/perl/*.pl $PREFIX/bin/.
mv $PREFIX/share/RNAz/perl/RNAz.pm $PREFIX/lib/5.26.2/.
