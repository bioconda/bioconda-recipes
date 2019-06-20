#!/bin/bash

mkdir -p $PREFIX/bin

./configure --prefix=$PREFIX 
make
make install
