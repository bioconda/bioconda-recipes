#!/bin/bash

mkdir -p $PREFIX/bin
cd src
autoreconf -fi
./configure --prefix=$PREFIX
make
make install
