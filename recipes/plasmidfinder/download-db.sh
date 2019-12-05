#!/usr/bin/env bash

echo "Downloading PlasmidFinder database to ${PLASMID_DB}..."

cd ${PLASMID_DB}
wget https://bitbucket.org/genomicepidemiology/plasmidfinder_db/get/9cdf35065947.tar.gz
tar -xvf 9cdf35065947.tar.gz --strip-components 1
rm *.tar.gz
python INSTALL.py

echo "PlasmidFinder database is downloaded."

exit 0
