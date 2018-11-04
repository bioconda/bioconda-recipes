#!/bin/bash

BINARY_HOME=$PREFIX/bin
BBMAP_HOME=$PREFIX/opt/bbmap-$PKG_VERSION

cd $SRC_DIR

# copy source to bin
mkdir -p $PREFIX/bin
mkdir -p $BBMAP_HOME
cp -R $SRC_DIR/* $BBMAP_HOME/
cd $BBMAP_HOME && chmod a+x *.sh

#cd $BINARY_HOME
cd $BBMAP_HOME
find *.sh -type f -exec ln -s $BBMAP_HOME/{} $BINARY_HOME/{} \;
