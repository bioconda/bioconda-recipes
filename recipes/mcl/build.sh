#!/bin/bash
mkdir -p $PREFIX/bin
./configure --prefix=$PREFIX --enable-blast
make
sed -i.bak 's|/usr/local/bin/perl -w|/usr/bin/env perl|' src/alien/oxygen/src/mcxdeblast
sed -i.bak 's|/usr/local/bin/perl|perl|' scripts/clxdo
make install 



