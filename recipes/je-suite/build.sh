#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
bindir=$PREFIX/bin
mkdir -p $bindir
cp -r ./* $outdir/
sed -i'.bak' -E 's@^DIR=.+@DIR='$outdir'@g' $outdir/je
rm -f $outdir/je.bak
ln -s $outdir/je $PREFIX/bin/je
chmod 0755 "${PREFIX}/bin/je"
