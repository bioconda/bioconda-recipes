#!/bin/bash
outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $outdir/bin
mkdir -p $outdir/lib
mkdir -p $PREFIX/bin

# Compile
TERM=xterm ./gradlew clean installDist

# Copy into prefix
cp build/install/VarDict/lib/*.jar $outdir/lib
cp build/install/VarDict/bin/VarDict $outdir/bin/vardict-java
cp build/install/VarDict/bin/VarDict.bat $outdir/bin/vardict-java.bat
cp VarDict/teststrandbias.R $outdir/bin/vardict-strandbias
cp VarDict/testsomatic.R $outdir/bin/vardict-testsomatic
cp VarDict/var2vcf_valid.pl $outdir/bin/vardict-var2vcf
cp VarDict/var2vcf_paired.pl $outdir/bin/vardict-var2vcf-paired
chmod +x $outdir/bin/*
ln -s $outdir/bin/* $PREFIX/bin
