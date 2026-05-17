#!/bin/bash

set -euo pipefail

export PERL5LIB="$PREFIX/lib/perl5:${PERL5LIB:-}"

# Array::IntSpan is not available on conda-forge/bioconda
cpanm --notest --local-lib "$PREFIX" Array::IntSpan@2.003
mkdir -pv "$PREFIX/lib/perl5"
cp -rv lib/perl5/* "$PREFIX/lib/perl5/"

# Use INSTALLDIRS=site so that EXE_FILES (annapotater.pl) are installed to $PREFIX/bin
perl Makefile.PL INSTALLDIRS=site NO_PERLLOCAL=1 NO_PACKLIST=1
make
make test
make install

echo "Finding annapotater executable(s) in $PREFIX or else listing files in $PREFIX with annapotater in the name:"
#which annapotater.pl || find "$PREFIX" -name 'annapotater*' -executable -type f -print

cp scripts/annapotater.pl "$PREFIX/bin/annapotater.pl"
chmod +x "$PREFIX/bin/annapotater.pl"
