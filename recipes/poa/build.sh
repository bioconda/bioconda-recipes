#!/bin/bash

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib

make poa CC=$CC CXX=$CXX CFLAGS="$CFLAGS -fcommon -DUSE_WEIGHTED_LINKS -DUSE_PROJECT_HEADER -I."

cp poa $PREFIX/bin
cp make_pscores.pl $PREFIX/bin
cp liblpo.a $PREFIX/lib

