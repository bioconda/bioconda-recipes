#!/bin/sh
mkdir -p $PREFIX/krona
mv ./* $PREFIX/krona
cd $PREFIX/krona
./install.pl --prefix=$PREFIX
