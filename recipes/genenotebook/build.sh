#!/bin/bash

set -exo pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir $PREFIX/bin
ls -l .
cp -R * $outdir
ln -s $outdir/genenotebook $PREFIX/bin/genenotebook
#npm install --unsafe-perm --force
#ls -l .
#ls -l genenotebook_v$PKG_VERSION/
#cp -R genenotebook_v$PKG_VERSION/* $outdir/
#ls -l $outdir
#ln -s $outdir/genenotebook $PREFIX/bin
#chmod 0755 "${PREFIX}/bin/genenotebook"
