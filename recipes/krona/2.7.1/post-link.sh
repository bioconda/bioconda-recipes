echo "
Krona installed.  You still need to manually update the taxonomy
databases before Krona can generate taxonomic reports.  The update
script is ktUpdateTaxonomy.sh.  The default location for storing
taxonomic databases is $PREFIX/opt/krona/taxonomy

If you would like the taxonomic data stored elsewhere, simply replace
this directory with a symlink.  For example:

rm -rf $PREFIX/opt/krona/taxonomy
mkdir /path/on/big/disk/taxonomy
ln -s /path/on/big/disk/taxonomy $PREFIX/opt/krona/taxonomy
ktUpdateTaxonomy.sh
" > $PREFIX/.messages.txt
