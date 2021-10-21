#!/bin/bash
#outdir="$(dirname $(readlink -f $(which sirius)))/.."
outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
echo "OUTDIR: ${outdir}"
# unpack library directory

if [ "$(uname)" == "Darwin" ]; then
    # Do something under Mac OS X platform
    tar -xf $outdir/Contents/native.tgz -C $outdir/Contents/
    tar -xf $outdir/Contents/runtime.tgz -C $outdir/Contents/
    rm $outdir/Contents/native.tgz
    rm $outdir/Contents/runtime.tgz
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    # Do something under GNU/Linux platform
    echo $outdir
    tar -xf $outdir/lib.tgz -C $outdir/
    rm $outdir/lib.tgz
fi

test sirius -h