#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

# makefile wants to write a package version taken from git
# since this is no git repo, we do that manually to avoid a failure
echo $PKG_VERSION > VERSION
make -C src

PACKAGE_HOME=$PREFIX/opt/$PKG_NAME-$PKG_VERSION
mkdir -p $PREFIX/bin
mkdir -p $PACKAGE_HOME

cp -r * $PACKAGE_HOME
cd $PREFIX/bin
ln -s $PACKAGE_HOME/qtip qtip
