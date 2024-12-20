#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp *.jar $outdir/
cp *.jar $outdir/
ln -s $outdir/*.jar $outdir/orthocore_jar.jar
cp $RECIPE_DIR/orthocore.py $outdir/orthocore
ls -l $outdir
ln -s $outdir/orthocore $PREFIX/bin
chmod 0755 "${PREFIX}/bin/orthocore"

