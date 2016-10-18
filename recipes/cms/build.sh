#!/bin/bash

BINARY_HOME=$PREFIX/bin
PACKAGE_HOME=$PREFIX/opt/$PKG_NAME-$PKG_VERSION

cd $SRC_DIR
make
make clean

find cms/ -name "*.py" -exec chmod +x {} \;

mkdir -p $PREFIX/bin
mkdir -p $PACKAGE_HOME
cp -R $SRC_DIR/* $PACKAGE_HOME/
cd $PACKAGE_HOME/cms && chmod a+x *.py
find *.py -type f -exec ln -s $PACKAGE_HOME/cms/{} $BINARY_HOME/{} \;
cd $PACKAGE_HOME/cms/combine
find * -type f -exec ln -s $PACKAGE_HOME/cms/combine/{} $BINARY_HOME/{} \;
cd $PACKAGE_HOME/cms/model
find * -type f -exec ln -s $PACKAGE_HOME/cms/model/{} $BINARY_HOME/{} \;
