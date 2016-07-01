#!/bin/sh
set -x -e

export CC=${PREFIX}/bin/gcc
export CXX=${PREFIX}/bin/g++

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include -I${PREFIX}/include/bam"

rm -rf samtools
#We're installing this from conda
cp -rf ${PREFIX}/include/bam ./samtools
make


mkdir -p $PREFIX/bin
mkdir -p $PREFIX/scripts
mkdir -p $PREFIX/config

cp dwgsim $PREFIX/bin
cp dwgsim_eval $PREFIX/bin
cp scripts/dwgsim_eval_plot.py $PREFIX/bin

cd scripts

mkdir -p perl-build
cp ${RECIPE_DIR}/Build.PL perl-build
cp *.pl perl-build

cd perl-build
perl ./Build.PL
./Build manifest
./Build install --installdirs site
