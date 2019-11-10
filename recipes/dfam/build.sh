#!/bin/sh
set -x -e

mkdir -p $PREFIX/bin

ls -l
gunzip dfamscan.pl.gz
chmod 777 dfamscan.pl
cp dfamscan.pl $PREFIX/bin
cp $RECIPE_DIR/download-dfam.py $PREFIX/bin
chmod 777 $PREFIX/bin/download-dfam.py
