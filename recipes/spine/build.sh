#!/bin/bash

set -x -e

mkdir -p $PREFIX/bin

mkdir -p perl-build perl-build/lib
mv *pl perl-build
mv scripts/*pl perl-build
#mv *.pm perl-build/lib/
cp ${RECIPE_DIR}/Build.PL perl-build

cd perl-build

perl ./Build.PL
perl ./Build manifest
perl ./Build install --installdirs site

chmod +rx $PREFIX/bin/nucmer_multi.pl
chmod +rx $PREFIX/bin/spine.pl
chmod +rx $PREFIX/bin/nucmer_backbone.pl
