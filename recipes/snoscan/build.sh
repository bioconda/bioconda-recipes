#!/bin/sh

set -eu

make -C squid-1.5.11 CC="$CC" CFLAGS="$CFLAGS"
make CC="$CC" CFLAGS="$CFLAGS"

mv sort-snos sort-snos.pl

## Build Perl

mkdir perl-build
#mv sort-snos perl-build
find . -name '*.pl' ! -path './perl-build/*.pl' -exec mv {} perl-build \;
# find . -name "*.pm`" | xargs -I {} cp {} perl-build/lib
cd perl-build
cp ${RECIPE_DIR}/Build.PL ./
perl ./Build.PL
perl ./Build manifest
perl ./Build install --installdirs site

cd ..
## End build perl

ln -s $PREFIX/bin/sort-snos.pl  $PREFIX/bin/sort-snos

mv snoscan snoscan[AHY] $PREFIX/bin

chmod u+rwx $PREFIX/bin/*
