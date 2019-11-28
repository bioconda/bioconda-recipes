#!/bin/bash
outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R * $outdir/
cp $RECIPE_DIR/goenrichment.py $outdir/goenrichment
ls -l $outdir
ln -s $outdir/goenrichment $PREFIX/bin
chmod 0755 "${PREFIX}/bin/goenrichment"
