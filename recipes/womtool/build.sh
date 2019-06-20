#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
output=$PREFIX/share/$PKG_NAME
mkdir -p $outdir
mkdir -p $PREFIX/bin

#cd $SRC_DIR
sbt assembly

cp womtool/target/scala-*/womtool*.jar $outdir/womtool.jar
cp $RECIPE_DIR/womtool.py $outdir/womtool
chmod +x $outdir/womtool
ln -s $outdir/womtool $PREFIX/bin/womtool
ln -s $outdir $output
