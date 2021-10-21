#!/bin/bash
outdir=$(readlink -m "$(dirname $(readlink -f $(which sirius)))/..")
echo "OUTDIR_TEST_SH: ${outdir}"

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