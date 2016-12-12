#!/bin/sh
./configure --prefix=$PREFIX 
make
make install

ls -l $PREFIX/bin
