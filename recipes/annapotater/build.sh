#!/bin/bash

set -euo pipefail

export PERL5LIB="$PREFIX/lib/perl5:${PERL5LIB:-}"

# Array::IntSpan is not available on conda-forge/bioconda
cpanm --notest --local-lib "$PREFIX" Array::IntSpan@2.003

# Use INSTALLDIRS=site so that EXE_FILES (annapotater.pl) are installed to $PREFIX/bin
perl Makefile.PL INSTALLDIRS=site NO_PERLLOCAL=1 NO_PACKLIST=1
make
make test
make install
