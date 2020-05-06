#!/bin/bash

macse=$PREFIX/opt/$PKG_NAME-$PKG_VERSION
mkdir -p $macse
cp -r ./* $macse
chmod +x $macse/macse_v2.03.jar
mkdir -p $PREFIX/bin
ln -s $macse/macse_v2.03.jar $PREFIX/bin/macse