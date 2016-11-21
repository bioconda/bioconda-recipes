#!/bin/bash

fastqc=$PREFIX/opt/$PKG_NAME-$PKG_VERSION
mkdir $fastqc
cp -r ./* $fastqc
chmod +x $fastqc/fastqc
mkdir -p $PREFIX/bin
ln -s $fastqc/fastqc $PREFIX/bin/fastqc 

