#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME
mkdir -p $outdir
mkdir -p $PREFIX/bin

sbt assembly

cp target/scala-*/wdltool-*.jar $outdir/wdltool.jar
cp $RECIPE_DIR/wdltool.py ${PREFIX}/bin/wdltool
chmod a+x ${PREFIX}/bin/wdltool
