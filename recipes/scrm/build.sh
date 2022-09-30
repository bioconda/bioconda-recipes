#!/bin/bash

./bootstrap
make
mkdir -p $PREFIX/bin
mv scrm $PREFIX/bin
mkdir -p $PREFIX/share/man/man1
mv doc/scrm.1 $PREFIX/share/man/man1
