#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

cd $SRC_DIR

# Development version build
# sbt update
# sbt assembly
# cp target/scala-*/fgbio-*.jar $outdir/fgbio.jar

# Release jar
cp fgbio*.jar $outdir/fgbio.jar

cp $RECIPE_DIR/fgbio.py $outdir/fgbio
chmod +x $outdir/fgbio
ln -s $outdir/fgbio $PREFIX/bin/fgbio
