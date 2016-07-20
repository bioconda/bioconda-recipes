#!/bin/sh
set -x -e

mkdir -p $PREFIX/bin


chmod 777 dfamscan.pl
cp dfamscan.pl $PREFIX/bin
chmod 777 download-dfam.py
cp $RECIPE_DIR/download-dfam.py $PREFIX/bin
