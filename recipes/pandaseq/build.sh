#!/bin/bash

mkdir -p $PREFIX/bin

./autogen.sh 
./configure --prefix=$PREFIX
make 
make install
