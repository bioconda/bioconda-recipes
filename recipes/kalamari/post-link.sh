DB_PREFIX="$PREFIX/share/${PKG_NAME}-${PKG_VERSION}"
echo "
===================
Kalamari installed.

To download the files, run downloadKalamari.sh
This will load the files into:

* $DB_PREFIX/kalamari - the genomic files

Suggested directories if building databases:

* $DB_PREFIX/kraken1.kalamari - the Kraken1 database
* $DB_PREFIX/kraken2.kalamari - the Kraken2 database

For more refined options, please start with
  downloadKalamari.pl --help
===================

" > $PREFIX/.messages.txt
