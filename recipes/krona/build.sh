#!/bin/sh
mkdir -p $PREFIX/opt/$PKG_NAME-$PKG_VERSION
mv ./* $PREFIX/opt/$PKG_NAME-$PKG_VERSION
cd $PREFIX/opt/$PKG_NAME-$PKG_VERSION
./install.pl --prefix=$PREFIX
ln -s $PREFIX/opt/$PKG_NAME-$PKG_VERSION/updateTaxonomy.sh $PREFIX/bin/ktUpdateTaxonomy.sh
echo 1 > $PREFIX/opt/$PKG_NAME-$PKG_VERSION/taxonomy/placeholder
