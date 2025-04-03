#!/bin/bash

set -x -e

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${PREFIX}/lib"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -O3 -I${PREFIX}/include"


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

chmod 0755 $PREFIX/bin/mashtre*
chmod 0755 $PREFIX/bin/min_abundance*
