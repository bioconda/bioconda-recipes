#!/bin/sh

set -xe 

cd $SRC_DIR/src/irfinder && make -j ${CPU_COUNT} && mv irfinder $SRC_DIR/bin/util
cd $SRC_DIR/src/trim && make -j ${CPU_COUNT} && mv trim $SRC_DIR/bin/util
cd $SRC_DIR/src/winflat && make -j ${CPU_COUNT} && mv winflat $SRC_DIR/bin/util

irfinder_home=$PREFIX/opt/irfinder-$PKG_VERSION
mkdir -p $irfinder_home
cp -r $SRC_DIR/* $irfinder_home

mkdir -p $PREFIX/bin
ln -s $irfinder_home/bin/IRFinder $PREFIX/bin/IRFinder
