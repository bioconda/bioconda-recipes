#!/bin/sh
mkdir -p $PREFIX/bin
cd src
mv CCAT.h ccat.h
./make
mv ../bin/CCAT $PREFIX/bin
