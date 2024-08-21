#!/bin/bash

set -x -e -o pipefail

BINARY_HOME=$PREFIX/bin
BBMAP_HOME=$PREFIX/opt/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
DATA_HOME=$PREFIX/share/$PKG_NAME

mkdir -p $BINARY_HOME
mkdir -p $BBMAP_HOME
mkdir -p $DATA_HOME

chmod a+x *.sh

cp -Rf * $BBMAP_HOME/

find *.sh -type f -exec ln -sf $BBMAP_HOME/{} $BINARY_HOME/{} \;

cp -Rf $BBMAP_HOME/resources $DATA_HOME
