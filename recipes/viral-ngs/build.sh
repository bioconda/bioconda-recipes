#!/bin/bash

BINARY_HOME=$PREFIX/bin
PACKAGE_HOME=$PREFIX/opt/$PKG_NAME-$PKG_VERSION

cd $SRC_DIR

# remove files duplicated by conda packages
rm tools/binaries/V-Phaser-2.0/MacOSX/libgomp.1.dylib
#chmod +x tools/scripts/*

find tools/scripts/ pipes -name "*.py" -exec chmod +x {} \;
find tools/scripts/ pipes -name "*.sh" -exec chmod +x {} \;

# copy source to bin
mkdir -p $PREFIX/bin
mkdir -p $PACKAGE_HOME
cp -R $SRC_DIR/* $PACKAGE_HOME/
cd $PACKAGE_HOME && chmod a+x *.py

cd $PACKAGE_HOME
find *.py -type f -exec ln -s $PACKAGE_HOME/{} $BINARY_HOME/{} \;
