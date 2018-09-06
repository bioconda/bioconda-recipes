#!/bin/bash

set -exo pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir $PREFIX/bin
ls -l .
cp -R * $outdir
ln -s $outdir/genenotebook $PREFIX/bin/genenotebook

