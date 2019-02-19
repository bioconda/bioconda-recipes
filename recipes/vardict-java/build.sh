#!/bin/bash
outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $outdir/bin
mkdir -p $outdir/lib
mkdir -p $PREFIX/bin

cp lib/*.jar $outdir/lib
cp bin/VarDict $outdir/bin/vardict-java
cp bin/*.{R,pl} $outdir/bin
for executable in vardict-java testsomatic.R teststrandbias.R var2vcf_paired.pl var2vcf_valid.pl; do
  chmod +x $outdir/bin/$executable
  ln -s $outdir/bin/$executable $PREFIX/bin
done
