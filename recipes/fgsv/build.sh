#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME
mkdir -p $outdir
mkdir -p $PREFIX/bin

cd $SRC_DIR

# Release jar
cp fgsv*.jar $outdir/fgsv.jar

cp $RECIPE_DIR/fgsv.py ${PREFIX}/bin/fgsv
chmod +x ${PREFIX}/bin/fgsv
