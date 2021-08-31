#!/bin/bash

mkdir -p $PREFIX
ln -s NOVOPlasty${PKG_VERSION}.pl NOVOPlasty.pl
chmod +x NOVOPlasty*.pl

## Build Perl

mkdir perl-build
find . -name "*.pl" | xargs -I {} mv {} perl-build
# find . -name "*.pm`" | xargs -I {} cp {} perl-build/lib
cd perl-build
cp ${RECIPE_DIR}/Build.PL ./
perl ./Build.PL
perl ./Build manifest
perl ./Build install --installdirs site

cd ..
## End build perl
