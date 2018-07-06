#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

cd $SRC_DIR

cp * $outdir
cp -R blast_database $outdir
cp -R PathoScope $outdir
chmod +x $outdir/*.sh
ln -s $outdir/grid.sh $PREFIX/bin/grid.sh
ln -s $outdir/update_database.sh $PREFIX/bin/update_database.sh
