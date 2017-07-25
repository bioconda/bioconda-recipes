#!/bin/bash

mkdir -p $PREFIX/bin

if [ "$build_os" == "Darwin" ]; then
  export CPPFLAGS="-I$PREFIX/include  --prefix=$PREFIX --with-boost=$PREFIX/include --stdlib=libstdc++"
else
  export CPPFLAGS="-I$PREFIX/include --prefix=$PREFIX --with-boost=$PREFIX/include"
fi

./configure --enable-maxk=96
make AM_CXXFLAGS=-Wall
make install

