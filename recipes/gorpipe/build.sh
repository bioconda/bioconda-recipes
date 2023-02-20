#!/bin/bash

GORPIPEDIR=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $GORPIPEDIR
cp -r ./* $GORPIPEDIR
mkdir -p $PREFIX/bin
ln -fs $GORPIPEDIR/bin/gorpipe $PREFIX/bin/gorpipe

