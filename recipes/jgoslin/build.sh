#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R * $outdir/
cp $RECIPE_DIR/jgoslin.py $outdir/jgoslin
ls -l $outdir
ln -s $outdir/jgoslin $PREFIX/bin
mv download_file?file_path=de%2Fisas%2Flipidomics%2F${PKG_NAME}-cli%2F${PKG_VERSION}%2F${PKG_NAME}-cli-${PKG_VERSION}.jar ${PKG_NAME}-cli-${PKG_VERSION}.jar
chmod 0755 "${PREFIX}/bin/jgoslin"
