#!/bin/bash

#Building according to instructions at AdapterRemoval repository

export CFLAGS="-I$PREFIX/include"
export CXXFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

make
make install PREFIX=$PREFIX
