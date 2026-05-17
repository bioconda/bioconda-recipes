#!/bin/bash

set -euo pipefail

# Install Array::IntSpan from bundled source (not on conda-forge/bioconda)
cd "$SRC_DIR/Array-IntSpan"
perl Makefile.PL INSTALLDIRS=site
make
make install

# Build annapotater
cd "$SRC_DIR/annapotater"
perl Makefile.PL INSTALLDIRS=site NO_PERLLOCAL=1 NO_PACKLIST=1
make
make test
make install

cp scripts/annapotater.pl "$PREFIX/bin/annapotater.pl"
chmod +x "$PREFIX/bin/annapotater.pl"
