#!/bin/bash

set -euo pipefail

# Array::IntSpan is not on conda-forge/bioconda; PERL_MM_OPT ensures cpanm
# installs to the versioned site_perl path that Perl's @INC already searches
export PERL_MM_OPT="INSTALLDIRS=site"
cpanm --notest Array::IntSpan@2.003

perl Makefile.PL INSTALLDIRS=site NO_PERLLOCAL=1 NO_PACKLIST=1
make
make test
make install

cp scripts/annapotater.pl "$PREFIX/bin/annapotater.pl"
chmod +x "$PREFIX/bin/annapotater.pl"
