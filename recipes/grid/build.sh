#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

cd $SRC_DIR

cp grid GRiD*.R README.md update_database check_R_libraries.R $outdir
cp -R blast_database $outdir
chmod +x $outdir/grid $outdir/update_database
ln -s $outdir/grid $PREFIX/bin/grid
ln -s $outdir/update_database $PREFIX/bin/update_database
