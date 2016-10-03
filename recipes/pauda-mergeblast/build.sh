#!/bin/bash

set -x -e

export PATH=$PREFIX/bin:$PATH
mkdir -p $PREFIX/bin

mkdir -p perl-build
mv *pl perl-build
cp ${RECIPE_DIR}/Build.PL perl-build

cd perl-build

perl ./Build.PL
perl ./Build manifest
perl ./Build install --installdirs site
