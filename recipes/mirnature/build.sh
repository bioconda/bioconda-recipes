#!/bin/bash

set -xe

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/scripts
mkdir -p ${PREFIX}/config

## Build Perl

mkdir perl-build
find scripts -name "*.pl" | xargs -I {} mv {} perl-build
cd perl-build

cp ${RECIPE_DIR}/Build.PL ./

perl Build.PL
perl ./Build
perl ./Build test
perl ./Build install --installdirs site

cd ..

## End build perl

mv bin/* $PREFIX/bin/
mv scripts/* $PREFIX/bin/
mv config/* $PREFIX/config/
