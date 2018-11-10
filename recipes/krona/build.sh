#!/bin/sh
mkdir -p $PREFIX/opt/krona
mv ./* $PREFIX/opt/krona
cd $PREFIX/opt/krona
./install.pl --prefix=$PREFIX
ln -s $PREFIX/opt/krona/updateTaxonomy.sh $PREFIX/bin/ktUpdateTaxonomy.sh
mkdir $PREFIX/bin/scripts
ln -s $PREFIX/opt/krona/scripts/taxonomy.make $PREFIX/bin/scripts/taxonomy.make
ln -s $PREFIX/opt/krona/scripts/extractTaxonomy.pl $PREFIX/bin/scripts/extractTaxonomy.pl
chmod +x $PREFIX/bin/scripts/extractTaxonomy.pl

echo 1 > $PREFIX/opt/krona/taxonomy/placeholder
