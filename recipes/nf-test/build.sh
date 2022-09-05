#!/bin/bash

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p "$outdir"
mkdir -p "$PREFIX/bin"
mv nf-test* "$outdir/"
chmod +x "$outdir/nf-test"

ln -s "$outdir/nf-test" "$PREFIX/bin"
