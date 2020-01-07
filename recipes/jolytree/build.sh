#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R * $outdir/

cp JolyTree.sh $outdir/JolyTree.sh
ls -l $outdir
ln -s $outdir/JolyTree.sh $PREFIX/bin
chmod 0755 "${PREFIX}/bin/JolyTree.sh"
