#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

cp jclusterfunk jclusterfunk.jar $outdir/

ln -s $outdir/jclusterfunk $PREFIX/bin
chmod 0755 "${PREFIX}/bin/jclusterfunk"
