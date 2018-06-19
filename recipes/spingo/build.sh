#!/bin/sh

export CXX=${PREFIX}/bin/g++
export CPPFLAGS="-I$PREFIX/include"
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

cd source
make boost-fix=1
mkdir -p $PREFIX/bin
cp spingo spindex $PREFIX/bin
cp ../dist/*.py $PREFIX/bin
chmod a+x $PREFIX/bin/*.py
