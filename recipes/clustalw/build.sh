#!/bin/bash

mkdir -p ${PREFIX}/bin
./configure --prefix=$PREFIX/bin
make install
