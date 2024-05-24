#!/bin/bash

set -eu -o pipefail

export LD_LIBRARY_PATH="${PREFIX}/lib"

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

cp hap-ibd.jar $outdir/hap-ibd.jar
cp $RECIPE_DIR/hap-ibd.py $outdir/hap-ibd

ln -s $outdir/hap-ibd $PREFIX/bin
chmod 0755 "${PREFIX}/bin/hap-ibd"
