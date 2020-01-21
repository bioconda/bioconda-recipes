#!/bin/bash
set -eu -o pipefail

# Use samtools by chromosome to avoid pulling the full genome into memory
sed -i 's/if (-e "$bedfile") { $USEFAIDX = 0; }/if (-e "$bedfile") { $USEFAIDX = 1; }/g' FindVariants.pl

# Use system bamtools instead of local, which doesn't load libbamtools
sed -i "s:\$Bin/bamtools-2.3.0/bin/::g" Utils.pm
sed -i "s:\$Bin/bamtools-2.3.0/bin/::g" SequenceIO.pm
# Use system samtools and bcftools
sed -i "s:\$Bin/samtools-1.1/::g" Utils.pm
sed -i "s:\$Bin/bcftools-1.1/::g" Utils.pm
# Perl libraries point to installation, handling symlinks
sed -i 's:$Bin:$RealBin:g' scalpel-discovery
sed -i 's:$Bin:$RealBin:g' scalpel-export
sed -i 's:$Bin:$RealBin:g' Utils.pm
# Use bash instead of /bin/sh default, which points to dash on ubuntu
sed -i "s:system(\$cmd):system(\"/bin/bash -c '\$cmd'\"):g" Utils.pm
# Avoid building samtools bcftools
sed -i "s/bamtools samtools bcftools//g" Makefile
# Use g++ in container
sed -i.bak "s#g++#${CXX}#" Microassembler/Makefile
sed -i.bak "s#g++#${CXX}#" Makefile

chmod 0755 FindVariants.pl
chmod 0755 FindSomatic.pl

ls -lh $BUILD_PREFIX/include/bamtools
make INCLUDES="-I$BUILD_PREFIX/include/bamtools -L $BUILD_PREFIX/lib" Microassembler
make INCLUDES="-I$BUILD_PREFIX/include/bamtools -L $BUILD_PREFIX/lib"

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
cp -r * $outdir
mkdir -p $PREFIX/bin
ln -s $outdir/scalpel-discovery $PREFIX/bin
ln -s $outdir/scalpel-export $PREFIX/bin
