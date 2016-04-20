#!/bin/sh
mkdir -p $PREFIX/opt/krona
mv ./* $PREFIX/opt/krona
cd $PREFIX/opt/krona
./install.pl --prefix=$PREFIX
