#!/bin/bash
cmake -D CMAKE_INSTALL_PREFIX:PATH=$PREFIX .
make
mkdir -p $PREFIX/bin
cp bin/* $PREFIX/bin
