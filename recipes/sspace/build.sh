#!/bin/bash

mkdir -p $PREFIX/opt/sspace
mv ./* $PREFIX/opt/sspace
cd $PREFIX/opt/sspace
ln -s $PREFIX/opt/sspace/SSPACE_Standard_v3.0.pl $PREFIX/bin/SSPACE_Standard_v3.0.pl
ln -s $PREFIX/opt/sspace/SSPACE_Standard_v3.0.pl $PREFIX/bin/SSPACE

cd $PREFIX/opt/sspace/dotlib/
wget -c http://cpansearch.perl.org/src/GBARR/perl5.005_03/lib/getopts.pl

