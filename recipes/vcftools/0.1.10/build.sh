#!/bin/bash

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
sed -i -e 's/DIRS = cpp perl/DIRS = cpp/' ./Makefile
make
make install
