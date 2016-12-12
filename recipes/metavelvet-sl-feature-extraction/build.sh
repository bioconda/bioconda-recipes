#!/bin/bash
set -x -e

export CC=${PREFIX}/bin/gcc
export CXX=${PREFIX}/bin/g++

find -name "*pm~" -delete

mkdir -p perl-build
mv FeatureExtract.perl perl-build/FeatureExtract.pl
mv FeatureExtractPredict.perl perl-build/FeatureExtractPredict.pl

mv BLAST_map perl-build/lib
cp ${RECIPE_DIR}/Build.PL perl-build

cd perl-build

mv lib/eval.pl ./
perl ./Build.PL
./Build manifest
./Build install --installdirs site
