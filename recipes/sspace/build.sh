#!/bin/bash

mkdir -p $PREFIX/bin/
mv * $PREFIX/bin
ln -s $PREFIX/bin/SSPACE_Standard_v3.0.pl $PREFIX/bin/SSPACE
cd $PREFIX/bin/dotlib/
wget -c http://cpansearch.perl.org/src/GBARR/perl5.005_03/lib/getopts.pl

