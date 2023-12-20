#!/bin/bash

set -x -e

export INCLUDE_PATH="${BUILD_PREFIX}/include"
export LIBRARY_PATH="${BUILD_PREFIX}/lib"
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${BUILD_PREFIX}/lib"

export LDFLAGS="-L${BUILD_PREFIX}/lib"
export CPPFLAGS="-I${BUILD_PREFIX}/include"


mkdir -p $$PREFIX/bin

mkdir -p perl-build
mv bin/*pl perl-build
mv bin/mashtree perl-build
mv lib/ perl-build/lib
cp ${RECIPE_DIR}/Build.PL perl-build

cd perl-build

perl ./Build.PL
perl ./Build manifest
perl ./Build install --installdirs site

chmod +x $PREFIX/bin/mashtre*
chmod +x $PREFIX/bin/min_abundance*
