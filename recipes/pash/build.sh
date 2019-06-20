#!/bin/bash

mkdir -p $PREFIX/bin/
sed -i.bak "s|INSTALLDIR=|INSTALLDIR=$PREFIX/bin/|g" Makefile.include
make
make install

mv $PREFIX/bin/keyFreq.exe $PREFIX/bin/keyFreq
mv $PREFIX/bin/makeIgnoreList.exe $PREFIX/bin/makeIgnoreList
mv $PREFIX/bin/pash2SAM.exe $PREFIX/bin/pash2SAM
mv $PREFIX/bin/pash-3.0lx.exe $PREFIX/bin/pash-3.0lx

cp -r rubyLib/* $PREFIX/lib/ruby/2.2.0/
