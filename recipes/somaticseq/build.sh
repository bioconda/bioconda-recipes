#!/usr/bin/env bash

PACKAGE_HOME=$PREFIX/opt/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
BINARY_HOME=$PREFIX/bin

mkdir -p $PACKAGE_HOME
mkdir -p $BINARY_HOME

cp -r * $PACKAGE_HOME

for file in $PACKAGE_HOME/*.sh $PACKAGE_HOME/*.py
do
  ln -s $file $BINARY_HOME
done

mkdir -p $BINARY_HOME/utilities

for file in $PACKAGE_HOME/utilities/*
do
  ln -s $file $BINARY_HOME/utilities
done

mkdir -p $BINARY_HOME/r_scripts
for file in $PACKAGE_HOME/r_scripts/*
do
  ln -s $file $BINARY_HOME/r_scripts
done
