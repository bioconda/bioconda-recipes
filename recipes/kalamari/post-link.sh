DB_PREFIX="$PREFIX/share/${PKG_NAME}-${PKG_VERSION}"
echo "
===================
Kalamari installed.
Please follow these next steps in order:

# downloads the files into $DB_PREFIX/kalamari
downloadKalamari.sh
# builds a modified taxonomy directory at $DB_PREFIX/taxonomy
buildTaxonomy.sh
# filters the taxonomy directory into just taxa that are used in Kalamari into $DB_PREFIX/taxonomy/filtered
filterTaxonomy.sh

Use the following scripts to build either a Kraken1 or Kraken2 database.
They require the filtered taxonomy step, outlined above.

buildKraken1.sh # requires conda install 'kraken<2'
buildKraken2.sh # requires conda install kraken2

To download a pre-built Mash database, use the following:
curl -L -o $DB_PREFIX/kalamari-v${PKG_VERSION}.msh https://github.com/lskatz/Kalamari/releases/download/v${PKG_VERSION}/kalamari-v${PKG_VERSION}.msh

For more refined options, please start with
  downloadKalamari.pl --help
===================

" > $PREFIX/.messages.txt
