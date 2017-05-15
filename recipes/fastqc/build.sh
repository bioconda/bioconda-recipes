#!/bin/bash

fastqc=$PREFIX/opt/$PKG_NAME-$PKG_VERSION
mkdir -p $fastqc
cp -r ./* $fastqc
sed -i '1 s|^.*$|#!/usr/bin/env perl|g' $fastqc/fastqc
chmod +x $fastqc/fastqc
mkdir -p $PREFIX/bin
ln -s $fastqc/fastqc $PREFIX/bin/fastqc 

