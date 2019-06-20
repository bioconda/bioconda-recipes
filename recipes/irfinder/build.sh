#!/bin/sh

cd $SRC_DIR/src/irfinder && make && mv irfinder $SRC_DIR/bin/util
cd $SRC_DIR/src/trim && make && mv trim $SRC_DIR/bin/util
cd $SRC_DIR/src/winflat && make && mv winflat $SRC_DIR/bin/util

irfinder_home=$PREFIX/opt/irfinder-$PKG_VERSION
mkdir -p $irfinder_home
cp -r $SRC_DIR/* $irfinder_home

mkdir -p $PREFIX/bin
ln -s $irfinder_home/bin/IRFinder $PREFIX/bin/IRFinder
