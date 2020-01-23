#!/bin/bash

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib

make poa CC=$CC CXX=$CXX

cp poa $PREFIX/bin
cp make_pscores.pl $PREFIX/bin
cp liblpo.a $PREFIX/lib

