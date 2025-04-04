#!/bin/sh
set -x -e

mkdir -p $PREFIX/bin

cp $RECIPE_DIR/Build.PL ./
${PREFIX}/bin/perl ./Build.PL
${PREFIX}/bin/perl ./Build manifest
${PREFIX}/bin/perl ./Build install --installdirs site

mv *pm $PREFIX/bin/
