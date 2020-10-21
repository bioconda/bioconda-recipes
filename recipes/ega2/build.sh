#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
cp EGA_download_client_*/EgaDemoClient.jar $outdir

mkdir -p $PREFIX/bin
cp $RECIPE_DIR/ega2.py $outdir/ega2
ln -s $outdir/ega2 $PREFIX/bin
chmod 0755 "${PREFIX}/bin/ega2"
