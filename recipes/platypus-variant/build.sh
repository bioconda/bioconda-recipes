#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
export C_INCLUDE_PATH=$PREFIX/include && export LIBRARY_PATH=$PREFIX/dir/lib && ./buildPlatypus.sh 
cp -r * $outdir
cp $RECIPE_DIR/platypus.sh $outdir/platypus
ln -s $outdir/platypus $PREFIX/bin
