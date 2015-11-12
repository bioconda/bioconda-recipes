#!/bin/sh

./configure --prefix=$PREFIX --with-python CFLAGS="-I$PREFIX/include" CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib" 

sed "s/^PYTHONVERS = /PYTHONVERS = python${PY_VER}/" Makefile -i
make 
make install

