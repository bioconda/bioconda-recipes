#!/bin/sh
set -x -e

mkdir -p $PREFIX/bin

cp $RECIPE_DIR/Build.PL ./
perl ./Build.PL
./Build manifest
./Build install --installdirs site

mv *pm $PREFIX/bin/
