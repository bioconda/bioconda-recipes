#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R * $outdir/
cp $RECIPE_DIR/PGDSpider2-gui.py $outdir/PGDSpider2-gui
cp $RECIPE_DIR/PGDSpider2-cli.py $outdir/PGDSpider2-cli
ls -l $outdir
ln -s $outdir/PGDSpider2-gui $PREFIX/bin
ln -s $outdir/PGDSpider2-cli $PREFIX/bin
chmod 0755 "${PREFIX}/bin/PGDSpider2-gui"
chmod 0755 "${PREFIX}/bin/PGDSpider2-cli"
