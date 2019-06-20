#!/bin/bash

set -x -e


export LD_LIBRARY_PATH="${PREFIX}/lib"

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp beagle.21Jan17.6cc.jar $outdir/beagle.jar
cp $RECIPE_DIR/beagle $outdir/
chmod +x $outdir/beagle
ln -s $outdir/beagle $PREFIX/bin

