#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' seqlogo
mv $SRC_DIR/* $outdir
BINDIR=$PREFIX/bin
mkdir -p $BINDIR
seqlogo=$BINDIR/seqlogo
echo "#! /bin/bash" > $seqlogo;
echo 'DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )' >>  $seqlogo;
echo '$DIR/../share/'$(basename $outdir)/seqlogo '$@' >> $seqlogo;
chmod +x $seqlogo
