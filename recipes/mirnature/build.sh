#!/bin/bash

set -xe

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/scripts
mkdir -p ${PREFIX}/config

## Build Perl

mkdir perl-build
cp -r script perl-build/.
cp -r lib perl-build/.
cd perl-build

cp ${RECIPE_DIR}/Build.PL ./

perl Build.PL
perl ./Build
perl ./Build test
perl ./Build install --installdirs site

cd ..
