#!/bin/bash
outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

cp -r * $outdir
# Remove test files
rm -f $outdir/hg19_*.txt.gz
rm -f $outdir/my.*

ln -s $outdir/vardict.pl $PREFIX/bin/vardict
ln -s $outdir/vardict.pl $PREFIX/bin
ln -s $outdir/testsomatic.R $PREFIX/bin
ln -s $outdir/teststrandbias.R $PREFIX/bin
ln -s $outdir/var2vcf_valid.pl $PREFIX/bin
ln -s $outdir/var2vcf_paired.pl $PREFIX/bin
ln -s $outdir/vardict2mut.pl $PREFIX/bin
