#!/bin/bash

mkdir -p $PREFIX/bin
mkdir -p perl-build
mv *pl perl-build
mv ISScripts perl-build/lib
cp ${RECIPE_DIR}/Build.PL perl-build

cd perl-build

rm lib/setup.sh
perl ./Build.PL
perl ./Build manifest
perl ./Build install --installdirs site
