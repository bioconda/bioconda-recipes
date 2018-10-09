#!/bin/bash

#strictly use anaconda build environment
export CC=${PREFIX}/bin/gcc
export CXX=${PREFIX}/bin/g++
export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"

mkdir -p $PREFIX/bin

METADIR=`pwd`

make clean
make

cp meta-velvetg ${PREFIX}/bin

mkdir -p perl-build
mv *pl perl-build
mv ISScripts perl-build/lib
cp ${RECIPE_DIR}/Build.PL perl-build

cd perl-build

rm lib/setup.sh
perl ./Build.PL
perl ./Build manifest
perl ./Build install --installdirs site

#mv * $PREFIX/bin/
