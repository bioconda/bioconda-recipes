#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

cd $SRC_DIR
sbt assembly

cp target/scala-*/cromwell-*.jar $outdir/cromwell.jar
cp $RECIPE_DIR/cromwell.py $outdir/cromwell
chmod +x $outdir/cromwell
ln -s $outdir/cromwell $PREFIX/bin/cromwell
