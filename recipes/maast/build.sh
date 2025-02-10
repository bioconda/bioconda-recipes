#!/bin/bash

BINARY_HOME=$PREFIX/bin
PACKAGE_HOME=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

## change to source dir
cd ${SRC_DIR}

## compile
make

## install
mkdir -p $PREFIX/bin
mkdir -p $PACKAGE_HOME

cp -R bin align_io db_io snps_io maast  $PACKAGE_HOME
ln -s $PACKAGE_HOME/maast $BINARY_HOME
