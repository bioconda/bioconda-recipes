#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME
mkdir -p $outdir
mkdir -p $PREFIX/bin

cd $SRC_DIR

# Release jar
cp calitas*.jar $outdir/calitas.jar

cp $RECIPE_DIR/calitas.py ${PREFIX}/bin/calitas
chmod +x ${PREFIX}/bin/calitas
