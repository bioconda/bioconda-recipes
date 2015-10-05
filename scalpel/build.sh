#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
reldir=../share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

# Use samtools by chromosome to avoid pulling the full genome into memory
sed -i 's/if (-e "$bedfile") { $USEFAIDX = 0; }/if (-e "$bedfile") { $USEFAIDX = 1; }/g' FindVariants.pl

# Perl libraries point to installation
sed -i "s:use Usage;:use lib \"\$Bin/$reldir\";\nuse Usage;:g" scalpel-discovery
sed -i "s:use Usage;:use lib \"\$Bin/$reldir\"\";\nuse Usage;:g" scalpel-export
sed -i "s:use Usage;:use lib \"\$Bin/$reldir\"\";\nuse Usage;:g" Utils.pm

# Use system bamtools instead of local, which doesn't load libbamtools
sed -i "s:\$Bin/bamtools-2.3.0/bin/::g" Utils.pm
sed -i "s:\$Bin/bamtools-2.3.0/bin/::g" SequenceIO.pm
# Use system samtools and bcftools
sed -i "s:\$Bin/samtools-1.1/::g" Utils.pm
sed -i "s:\$Bin/bcftools-1.1/::g" Utils.pm
# Ensure local scripts point to installation
sed -i "s:\$Bin/:\$Bin/$reldir/:g" Utils.pm
# Use bash instead of /bin/sh default, which points to dash on ubuntu
sed -i "s:system(\$cmd):system(\"/bin/bash -c '\$cmd'\"):g" Utils.pm
# Avoid building samtools bcftools
sed -i "s/bamtools samtools bcftools//g" Makefile

chmod 0755 FindVariants.pl
chmod 0755 FindSomatic.pl

make INCLUDES="-I$PREFIX/include/bamtools -L $PREFIX/lib" Microassembler
make INCLUDES="-I$PREFIX/include/bamtools -L $PREFIX/lib"

cp -r * $outdir
ln -s $outdir/scalpel-discovery $PREFIX/bin
