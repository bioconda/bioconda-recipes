#!/bin/bash

outdir=$PREFIX/share/$PKG_NAME
mkdir -p $outdir
mkdir -p $PREFIX/bin

./install.sh

# install wrapper script
cp $RECIPE_DIR/mobster.py $outdir/mobster.py
chmod +x $outdir/mobster.py
ln -s $outdir/mobster.py $PREFIX/bin/mobster

# copy jar
cp target/MobileInsertions-$PKG_VERSION.jar $outdir/
