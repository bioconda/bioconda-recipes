#!/bin/sh
mkdir -p $PREFIX/bin
cd src
./make
mv ../bin/CCAT $PREFIX/bin
