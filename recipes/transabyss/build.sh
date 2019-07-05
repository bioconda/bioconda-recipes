#!/bin/sh
set -x -e

TOPDIR=`pwd`

mkdir -p $PREFIX/bin

chmod 777 bin/*
cp bin/* $PREFIX/bin

mkdir -p $TOPDIR/scripts
mv transabyss $TOPDIR/scripts/
mv transabyss-merge $TOPDIR/scripts/

cd $TOPDIR/scripts/
2to3 -w *
cd $TOPDIR/utilities
2to3 -w *

cd $TOPDIR
cd utilities
sed -i.bak 's/from utilities import/from transabyss import/' *.py

cd $TOPDIR
mkdir transabyss
cp -rf utilities/* transabyss/

cp $RECIPE_DIR/setup.py ./
python setup.py build
python setup.py install
