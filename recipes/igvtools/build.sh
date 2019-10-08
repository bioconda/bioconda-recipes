#!/bin/bash
outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
echo "OUTDIR: $outdir"
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R ./* $outdir/
cp $RECIPE_DIR/igvtools.sh $outdir/igvtools
chmod +x $outdir/igvtools
ln -s $outdir/igvtools $PREFIX/bin
