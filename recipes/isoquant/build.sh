#!/bin/bash

OUTDIR=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $OUTDIR
mkdir -p $PREFIX/bin
chmod a+x *.py
cp -rp * "$OUTDIR/"
cd $PREFIX/bin
ln -s "../${OUTDIR#$PREFIX}"/*.py .
