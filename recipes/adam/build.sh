#!/bin/bash

BINARY_HOME=$PREFIX/bin
PACKAGE_HOME=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

mkdir -p $BINARY_HOME
mkdir -p $PACKAGE_HOME

cp -R distribution/* $PACKAGE_HOME
# for now, we download the egg file and package it
# to the make find_adam_egg.sh happy
cp -R python_egg/*.egg $PACKAGE_HOME

ln -s $PACKAGE_HOME/bin/adam-shell $BINARY_HOME
ln -s $PACKAGE_HOME/bin/adam-submit $BINARY_HOME
ln -s $PACKAGE_HOME/bin/pyadam $BINARY_HOME

# adam
$PYTHON -m pip install python_adam/. --no-deps --ignore-installed -vv

mkdir -p $PREFIX/repo


for f in $PACKAGE_HOME/*.egg; do
  ln -s $f $PREFIX/repo/
done

for f in $PACKAGE_HOME/repo/*.jar ; do
    ln -s $f $PREFIX/repo/
done
