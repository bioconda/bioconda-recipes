#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

cd $SRC_DIR
sbt assembly

# cromwell
cp server/target/scala-*/cromwell-*.jar $outdir/cromwell.jar
cp $RECIPE_DIR/cromwell.py $outdir/cromwell
chmod +x $outdir/cromwell
ln -s $outdir/cromwell $PREFIX/bin/cromwell

cp womtool/target/scala-*/womtool*.jar $outdir/womtool.jar
cp $RECIPE_DIR/womtool.py $outdir/womtool
chmod +x $outdir/womtool
ln -s $outdir/womtool $PREFIX/bin/womtool
