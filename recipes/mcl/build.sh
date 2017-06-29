#!/bin/bash
mkdir -p $PREFIX/bin
./configure --prefix=$PREFIX --enable-blast
make
make install 



