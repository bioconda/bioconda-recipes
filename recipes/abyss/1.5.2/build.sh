#!/bin/bash

mkdir -p $PREFIX/bin

if [[ "$OSTYPE" == "darwin"* ]]; then
  CPPFLAGS="-I$PREFIX/include --prefix=$PREFIX --with-boost=$PREFIX/include --stdlib=libstdc++"
else
  CPPFLAGS="-I$PREFIX/include --prefix=$PREFIX --with-boost=$PREFIX/include"
fi

./configure CPPFLAGS=${CPPFLAGS} --enable-maxk=96
make AM_CXXFLAGS=-Wall
make install

