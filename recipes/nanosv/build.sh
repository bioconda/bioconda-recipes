#!/bin/bash

set -x -e

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"


mkdir -p $PREFIX/bin

mkdir -p perl-build perl-build/lib
mv *pl perl-build
mv *.pm perl-build/lib/
cp ${RECIPE_DIR}/Build.PL perl-build

cd perl-build

perl ./Build.PL
perl ./Build manifest
perl ./Build install --installdirs site
