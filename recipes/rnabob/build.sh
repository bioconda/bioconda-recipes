#!/bin/sh
mkdir -p $PREFIX/share/man
make clean
make
make install HOME=$PREFIX
