#!/bin/bash

set -e -o pipefail

#cpanm DDP #only mac
cpanm LWP::UserAgent



outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

cp -r flatfiles $outdir
cp -r code $outdir


# make assign_genome_properties.pl available
ln -s $outdir/code/scripts/assign_genome_properties.pl $PREFIX/bin

mkdir -p ${PREFIX}/etc/conda/activate.d/
echo "export export PERL5LIB=$PERL5LIB:$outdir/code/modules" > ${PREFIX}/etc/conda/activate.d/${PKG_NAME}-${PKG_VERSION}.sh
