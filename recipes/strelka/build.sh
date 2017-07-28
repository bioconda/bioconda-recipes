#!/bin/bash
set -eu

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

cp -r bin lib libexec share $outdir
rm -rf $outdir/share/demo
sed -i.bak \
    -e "s~scriptDir=.*~scriptDir='$outdir/bin'~" \
    -e "s~workflowDir=.*~workflowDir='$outdir/lib/python'~" \
    $outdir/bin/configure*.py
ln -s $outdir/bin/config*.py $outdir/bin/run*.bash $PREFIX/bin
