#!/bin/bash

set -e -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin


mv CAT_pack $outdir

ln -s $outdir/CAT_pack/CAT $PREFIX/bin
