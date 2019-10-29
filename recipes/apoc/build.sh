#!/bin/sh

cd src/
make
mkdir -p ${PREFIX}/bin
mv apoc $PREFIX/bin
