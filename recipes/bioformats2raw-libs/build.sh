#!/bin/bash
set -eu

pkg=bioformats2raw-$PKG_VERSION-$PKG_BUILDNUM

libdir=$PREFIX/share/$pkg/lib
mkdir -p $libdir
cp -R $SRC_DIR/lib/* $libdir/