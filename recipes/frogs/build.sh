#!/bin/bash

BINARY_HOME=$PREFIX/bin
LIB_HOME=$PREFIX/lib
LIBEXEC_HOME=$PREFIX/libexec
SUPP_DATA=$PREFIX/frogsfunc_suppdata
FROGS_HOME=$PREFIX/share/FROGS-$PKG_VERSION

mkdir -p $PREFIX/share/
mkdir -p $FROGS_HOME
mkdir -p $BINARY_HOME
mkdir -p $LIB_HOME
mkdir -p $LIBEXEC_HOME
mkdir -p $SUPP_DATA

mv $SRC_DIR/* $FROGS_HOME

ln -s $FROGS_HOME/app/*html $BINARY_HOME
ln -s $FROGS_HOME/app/*py $BINARY_HOME
ln -s $FROGS_HOME/app/*Rmd $BINARY_HOME
ln -s $FROGS_HOME/lib/* $LIB_HOME
ln -s $FROGS_HOME/libexec/* $LIBEXEC_HOME
ln -s $FROGS_HOME/frogsfunc_suppdata/* $SUPP_DATA
ln -s $PREFIX/share/rdptools-2.0.3-1/classifier.jar $BINARY_HOME