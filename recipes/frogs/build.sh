#!/bin/bash

BINARY_HOME=$PREFIX/bin
LIB_HOME=$PREFIX/lib
LIBEXEC_HOME=$PREFIX/libexec
FROGS_HOME=$PREFIX/share/FROGS-$PKG_VERSION

mkdir -p $PREFIX/share/
mkdir -p $FROGS_HOME
mkdir -p $BINARY_HOME
mkdir -p $LIB_HOME
mkdir -p $LIBEXEC_HOME

mv $SRC_DIR/* $FROGS_HOME

ln -s $FROGS_HOME/app/* $BINARY_HOME
ln -s $FROGS_HOME/lib/* $LIB_HOME
ln -s $FROGS_HOME/libexec/* $LIBEXEC_HOME
ln -s $PREFIX/share/rdptools-*/classifier.jar $BINARY_HOME
