#!/bin/sh
mkdir -p $PREFIX/opt/krona
mv ./* $PREFIX/opt/krona
cd $PREFIX/opt/krona
./install.pl --prefix=$PREFIX
ln -s $PREFIX/opt/krona/updateTaxonomy.sh $PREFIX/bin/ktUpdateTaxonomy.sh
echo 1 > $PREFIX/opt/krona/taxonomy/placeholder
