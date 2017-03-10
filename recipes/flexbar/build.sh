#!/bin/bash

BINARY_HOME=$PREFIX/bin

mkdir -p $BINARY_HOME $PREFIX/share/doc/flexbar

cp flexbar $BINARY_HOME
# TBB is available in bioconda and conda-forge
#cp flexbar-$PKG_VERSION-*/libtbb.so.2 $PKG_HOME/lib
cp *.md $PREFIX/share/doc/flexbar
