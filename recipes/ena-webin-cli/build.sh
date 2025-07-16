#!/bin/bash

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R * $outdir/
cp $RECIPE_DIR/ena_webin_cli.py $outdir/ena-webin-cli
ls -l $outdir
ln -s $outdir/ena-webin-cli $PREFIX/bin/ena-webin-cli
chmod 0755 "${PREFIX}/bin/ena-webin-cli"
