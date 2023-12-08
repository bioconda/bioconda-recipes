#!/bin/bash
set -euxo pipefail
OUTDIR=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $OUTDIR
mkdir -p $PREFIX/bin
ln -s $OUTDIR/tw $PREFIX/bin
chmod 755 $PREFIX/bin/tw