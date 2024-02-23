#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R * $outdir/ 
ls -l $outdir
sed -i.bak '1 s|^.*$|#!/usr/bin/env python|g' $outdir/READ.py
ln -s $outdir/READ.py $PREFIX/bin/kinship-read
chmod 0755 ${PREFIX}/bin/kinship-read