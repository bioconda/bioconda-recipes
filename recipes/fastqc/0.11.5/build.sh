#!/bin/bash

fastqc=$PREFIX/opt/$PKG_NAME-$PKG_VERSION
mkdir -p $fastqc
cp -r ./* $fastqc
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $fastqc/fastqc
rm -f $fastqc/fastqc.bak
chmod +x $fastqc/fastqc
mkdir -p $PREFIX/bin
ln -s $fastqc/fastqc $PREFIX/bin/fastqc 

