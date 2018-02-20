#!/bin/bash
outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

cp -R * $outdir/
chmod -R 0755 "$outdir/bin/"

#Incorrect parsing of the version
sed -i.bak 's|require_version('roary'|#require_version('roary'|g' $outdir/bin/nullarbor.pl

ln -s $outdir/bin/nullarbor.pl $PREFIX/bin
ln -s $outdir/bin/fq $PREFIX/bin
ln -s $outdir/bin/fa $PREFIX/bin
ln -s $outdir/bin/roary2svg.pl $PREFIX/bin
ln -s $outdir/bin/afa-pairwise.pl $PREFIX/bin
ln -s $outdir/bin/any2fasta.pl $PREFIX/bin
ln -s $outdir/bin/nullarbor-report.pl $PREFIX/bin

