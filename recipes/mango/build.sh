#!/bin/bash

BINARY_HOME=$PREFIX/bin
PACKAGE_HOME=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

mkdir -p $BINARY_HOME
mkdir -p $PACKAGE_HOME

cp -R * $PACKAGE_HOME

ln -s $PACKAGE_HOME/bin/mango-notebook $BINARY_HOME
ln -s $PACKAGE_HOME/bin/mango-submit $BINARY_HOME
ln -s $PACKAGE_HOME/bin/make_genome $BINARY_HOME

