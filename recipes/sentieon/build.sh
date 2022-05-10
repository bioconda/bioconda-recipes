#!/bin/bash
set -eu

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

cp -r * $outdir

sed -i.bak s#!/bin/sh#!/bin/bash# $outdir/bin/sentieon
ln -s $outdir/bin/sentieon $PREFIX/bin/sentieon
ln -s $outdir/bin/bwa $PREFIX/bin/sentieon-bwa
