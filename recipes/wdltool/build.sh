#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

cd $SRC_DIR
sbt assembly

cp target/scala-*/wdltool-*.jar $outdir/wdltool.jar
cp $RECIPE_DIR/wdltool.py $outdir/wdltool
chmod +x $outdir/wdltool
ln -s $outdir/wdltool $PREFIX/bin/wdltool
