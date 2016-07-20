#!/bin/sh
set -x -e

mkdir -p $PREFIX/bin

chmod 777 dfamscan.pl
cp dfamscan.pl $PREFIX/bin
cp $RECIPE_DIR/download-dfam.sh $PREFIX/bin
