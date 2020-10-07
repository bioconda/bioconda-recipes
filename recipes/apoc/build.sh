#!/bin/sh

cd src/
make FC=$FC
mkdir -p ${PREFIX}/bin
mv apoc $PREFIX/bin
