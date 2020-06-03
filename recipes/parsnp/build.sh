#!/bin/bash


mkdir -p  "$PREFIX/bin"
export CC=gcc
export CXX=g++

cd muscle
./autogen.sh
./configure --prefix=$PWD
make install

cd ..
./autogen.sh
export ORIGIN=\$ORIGIN
./configure LDFLAGS='-Wl,-rpath,$$ORIGIN/../muscle/lib'
make LDADD=-lMUSCLE-3.7 
make install

cp parsnp bin/ muscle/ template.ini Parsnp.py  $PREFIX/bin/ -r

