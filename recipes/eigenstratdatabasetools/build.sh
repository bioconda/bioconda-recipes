#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R * $outdir/ 
ls -l $outdir
ln -s $outdir/eigenstrat_snp_coverage.py $PREFIX/bin/eigenstrat_snp_coverage
ln -s $outdir/eigenstrat_database_tools.py $PREFIX/bin/eigenstrat_database_tools
chmod 0755 ${PREFIX}/bin/eigenstrat_database_tools
chmod 0755 ${PREFIX}/bin/eigenstrat_snp_coverage
