#!/bin/bash

mkdir -p $PREFIX/bin/
sed -i.bak "s|INSTALLDIR=|INSTALLDIR=$PREFIX|g" Makefile.include
make
make install

cp -r rubyLib/* $PREFIX/lib/ruby/2.2.0/
