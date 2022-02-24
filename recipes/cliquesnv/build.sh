#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME
mkdir -p $outdir
mkdir -p $PREFIX/bin

cp clique-snv.jar $outdir/clique-snv.jar
cp $RECIPE_DIR/cliquesnv.py ${PREFIX}/bin/cliquesnv
chmod a+x ${PREFIX}/bin/cliquesnv
