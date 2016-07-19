#!/bin/sh
set -x -e

mkdir -p $PREFIX/bin

cp dfamscan.pl $PREFIX/bin
cp $RECIPE_DIR/download-dfam.sh $PREFIX/bin
