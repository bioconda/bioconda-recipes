#!/bin/sh

# For OSX configuration files are patched and autoconf is not necessary
touch -c configure.ac aclocal.m4 Makefile.am Makefile.in
./configure --with-logp=table --prefix=$PREFIX
make
make install
