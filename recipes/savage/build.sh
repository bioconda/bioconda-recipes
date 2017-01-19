#!/bin/bash

export CPP_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

make
mkdir -p $PREFIX/bin

PACKAGE_HOME=$PREFIX/opt/$PKG_NAME-$PKG_VERSION
mkdir -p $PACKAGE_HOME

cp $RECIPE_DIR/* $PACKAGE_HOME/
ln -s $PACKAGE_HOME/gatk.py $PREFIX/bin/savage # create a symbolic link
