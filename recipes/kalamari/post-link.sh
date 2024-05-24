DB_PREFIX="$PREFIX/share/${PKG_NAME}-${PKG_VERSION}"
echo "
===================
Kalamari installed.

To download the files, run downloadKalamari.sh
This will load the files into:

* $DB_PREFIX/kalamari - the genomic files

The following databases are available:
* buildTaxonomy.sh  - builds a modified taxonomy directory at $DB_PREFIX/taxonomy
* filterTaxonomy.sh - filters the taxonomy directory into just taxa that are used in Kalamari into $DB_PREFIX/taxonomy/filtered (requires taxonkit)

The following depend on a built taxonomy from buildTaxonomy.sh
* buildKraken1.sh - creates a Kraken1 database at $DB_PREFIX/kraken.kalamari (requires filterTaxonomy.sh, Kraken1)
* buildKraken2.sh - creates a Kraken2 database at $DB_PREFIX/kraken2.kalamari (requires filterTaxonomy.sh, Kraken2)

For more refined options, please start with
  downloadKalamari.pl --help
===================

" > $PREFIX/.messages.txt
