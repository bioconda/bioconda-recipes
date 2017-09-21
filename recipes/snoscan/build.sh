#!/bin/bash

set -eu -o pipefail

make -C squid-1.5j
make

mv sort-snos sort-snos.pl

## Build Perl

mkdir perl-build
#mv sort-snos perl-build
find . -name "*.pl" | xargs -I {} mv {} perl-build
# find . -name "*.pm`" | xargs -I {} cp {} perl-build/lib
cd perl-build
cp ${RECIPE_DIR}/Build.PL ./
perl ./Build.PL
perl ./Build manifest
perl ./Build install --installdirs site

cd ..
## End build perl

ln -s $PREFIX/bin/sort-snos.pl  $PREFIX/bin/sort-snos

mv snoscan $PREFIX/bin
