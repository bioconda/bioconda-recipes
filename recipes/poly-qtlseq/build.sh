#!/usr/bin/env bash

BINARY_HOME=$PREFIX/bin
PACKAGE_HOME=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

mkdir -p $BINARY_HOME
mkdir -p $PACKAGE_HOME

cp -r $SRC_DIR/* $PACKAGE_HOME
cp $RECIPE_DIR/polyQtlseq.sh $PACKAGE_HOME/polyQtlseq.sh
chmod +x $PACKAGE_HOME/polyQtlseq.sh
ln -s $PACKAGE_HOME/polyQtlseq.sh $BINARY_HOME/polyQtlseq
