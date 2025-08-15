#!/bin/bash

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R ./* $outdir/
ls $outdir/
mv $outdir/sem-$PKG_VERSION-jar-with-dependencies.jar $outdir/sem.jar
cp $RECIPE_DIR/sem.py $outdir/sem
chmod +x $outdir/sem

ln -s $outdir/sem $PREFIX/bin
