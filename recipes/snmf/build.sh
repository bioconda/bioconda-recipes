#!/bin/bash

snmf=$PREFIX/opt/$PKG_NAME-$PKG_VERSION
mkdir -p $snmf
mkdir -p $PREFIX/bin
cp -r ./* $PREFIX/bin
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $snmf/Snmf.pl
rm -f $PREFIX/Snmf.bak
chmod +x $PREFIX/snmf.sh
chmod +x $PREFIX/plink
chmod +x $PREFIX/install.command
make $PREFIX/install.command
chmod 777 $PREFIX/Snmf.pl
mkdir -p $PREFIX/opt/var
