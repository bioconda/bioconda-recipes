#!/bin/bash

mkdir -p $PREFIX/bin
sed -i.bak "1 s|/usr/bin/make|$PREFIX/bin/make|"  bin/abyss-pe
rm bin/abyss-pe.bak

./configure --prefix=$PREFIX --with-boost=$PREFIX/include --with-mpi=$PREFIX/include --enable-maxk=128
make AM_CXXFLAGS=-Wall
make install 
