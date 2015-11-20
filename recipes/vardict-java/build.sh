#!/bin/bash
outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $outdir/bin
mkdir -p $outdir/lib
mkdir -p $PREFIX/bin

cp lib/*.jar $outdir/lib
cp bin/VarDict $outdir/bin/vardict-java
chmod +x $outdir/bin/vardict-java
ln -s $outdir/bin/vardict-java $PREFIX/bin
