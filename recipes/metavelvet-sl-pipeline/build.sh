#!/bin/bash
set -x -e

mkdir -p perl-build

mv GenerateCommand.perl perl-build/GenerateCommand.pl
mv ReadTaxon.perl perl-build/ReadTaxon.pl
cp ${RECIPE_DIR}/Build.PL perl-build

cd perl-build
perl ./Build.PL
perl ./Build manifest
perl ./Build install --installdirs site
