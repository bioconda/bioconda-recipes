#!/bin/sh
mkdir -p $PREFIX/opt/krona
mv ./* $PREFIX/opt/krona
cd $PREFIX/opt/krona
./install.pl --prefix=$PREFIX
ln -s $PREFIX/opt/krona/updateTaxonomy.sh $PREFIX/bin/
echo 1 > $PREFIX/opt/krona/taxonomy/placeholder

echo "Krona installed.  You still need to manually call
updateTaxonomy.sh before Krona can generate taxonomic reports.  The
default location for storing taxonomic databases is
$PREFIX/opt/krona/taxonomy. If you would like the taxonomic data
stored elsewhere, simply replace this directory with a symlink to
another directory.  For example:

rm -rf $PREFIX/opt/krona/taxonomy
mkdir /path/to/big/drive/taxonomy
ln -s /path/to/big/drive/taxonomy $PREFIX/opt/krona/taxonomy
updateTaxonomy.sh
"
