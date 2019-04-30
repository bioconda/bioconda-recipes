#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME
mkdir -p $outdir
mkdir -p $PREFIX/bin

cd $SRC_DIR

# cromwell
cp cromwell/cromwell-*.jar $outdir/cromwell.jar
cp $RECIPE_DIR/cromwell.py ${PREFIX}/bin/cromwell

cp womtool/womtool-*.jar $outdir/womtool.jar
cp $RECIPE_DIR/womtool.py ${PREFIX}/bin/womtool
