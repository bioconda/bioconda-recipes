#!/bin/bash

BINARY_HOME=$PREFIX/bin
QUAST_HOME=$PREFIX/opt/quast-$PKG_VERSION

mkdir -p $BINARY_HOME
mkdir -p $QUAST_HOME

cp -R $SRC_DIR/* $QUAST_HOME

#Linking to binfolder
chmod +x $QUAST_HOME/quast.py
ln -s "$QUAST_HOME/quast.py" "$BINARY_HOME/quast"

chmod +x $QUAST_HOME/metaquast.py
ln -s "$QUAST_HOME/metaquast.py" "$BINARY_HOME/metaquast"
