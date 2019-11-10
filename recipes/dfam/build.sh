#!/bin/sh
set -x -e

mkdir -p $PREFIX/bin


chmod 777 dfamscan.pl
gunzip dfamscan.pl.gz
cp dfamscan.pl $PREFIX/bin
cp $RECIPE_DIR/download-dfam.py $PREFIX/bin
chmod 777 $PREFIX/bin/download-dfam.py
