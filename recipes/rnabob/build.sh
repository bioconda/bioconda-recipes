#!/bin/sh
mkdir -p $PREFIX/share/man/man1
make clean
make
make install HOME=$PREFIX
