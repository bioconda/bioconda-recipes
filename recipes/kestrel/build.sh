#!/bin/bash

kestrel=$PREFIX/opt/$PKG_NAME-$PKG_VERSION
mkdir -p $kestrel
cp -r ./* $kestrel
chmod +x $kestrel/kestrel
mkdir -p $PREFIX/bin
ln -s $kestrel/kestrel $PREFIX/bin/kestrel 

