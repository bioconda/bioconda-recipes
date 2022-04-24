#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp *.jar $outdir/
ln -s $outdir/*.jar $outdir/mzToSQLite.jar
cp $RECIPE_DIR/mz_to_sqlite.py $outdir/mz_to_sqlite
ls -l $outdir
ln -s $outdir/mz_to_sqlite $PREFIX/bin
chmod 0755 "${PREFIX}/bin/mz_to_sqlite"

