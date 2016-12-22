#!/bin/bash
# Extracted from from BRASS/setup.sh and BRASS/Makefile

# First compile the C++ parts
git clone git://git.code.sf.net/p/pstreams/code c++/pstreams
sed -ie 's#<pstreams/pstream.h>#"pstreams/pstream.h"#' c++/augment-bam.cpp
make -C c++
cp c++/augment-bam $PREFIX/bin
cp c++/brass-group $PREFIX/bin
cp c++/filterout-bam $PREFIX/bin

# Then install the perl helper scripts
cd perl && perl -MExtUtils::MakeMaker -e 1
cpanm --mirror http://cpan.metacpan.org --notest -l $PREFIX --installdeps .

sed -ie 's#$FindBin::Bin/../lib#$FindBin::Bin/../lib/perl5#' bin/*.pl

perl Makefile.PL INSTALL_BASE=$PREFIX && \
make && \
#make test && \
make install
