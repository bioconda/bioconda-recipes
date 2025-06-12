echo "
===================
SneakerNet depends on the Kalamari database.
This database is not included in the conda package.
You can download the database by running the following commands:

    downloadKalamari.sh
    buildTaxonomy.sh
    filterTaxonomy.sh
    buildKraken1.sh

===================

" > $PREFIX/.messages.txt
