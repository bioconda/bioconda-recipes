#!/bin/sh

# For OSX configuration files that are patched so autoreconf is not necessary
touch -c configure.ac aclocal.m4 Makefile.am Makefile.in
touch -c miscSupport/configure.ac miscSupport/aclocal.m4 miscSupport/Makefile.am miscSupport/Makefile.in
./configure --with-logp=table --prefix=$PREFIX
make
make install
