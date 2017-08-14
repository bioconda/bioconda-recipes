#!/bin/bash

snmf=$PREFIX/opt/$PKG_NAME-$PKG_VERSION
mkdir -p $snmf
mkdir -p $PREFIX/bin
cp -r ./* $PREFIX/bin
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PPREFIX/bin/snmf.pl
rm -f $PREFIX/bin/Snmf.bak
chmod +x $PREFIX/bin/snmf.sh
chmod +x $PREFIX/bin/plink
chmod +x $PREFIX/bin/install.command
make $PREFIX/bin/install.command
chmod 777 $PREFIX/bin/Snmf.pl
mkdir -p $PREFIX/bin/opt/var
