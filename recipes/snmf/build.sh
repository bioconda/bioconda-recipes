#!/bin/bash

snmf=$PREFIX/opt/$PKG_NAME-$PKG_VERSION
mkdir -p $snmf
cp -r ./* $snmf/
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $snmf/Snmf.pl
rm -f $snmf/Snmf.bak
chmod +x $snmf/snmf.sh
chmod +x $snmf/plink
chmod +x $snmf/install.command
make $snmf/install.command
chmod 777 $snmf/Snmf.pl
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/opt/var
export PATH=$snmf:$PATH >> ./bash_profile
