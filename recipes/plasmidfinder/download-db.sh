#!/usr/bin/env bash

TARGET_DIR=${1:-$PLASMID_DB}

echo "Downloading PlasmidFinder 2.1 database to ${TARGET_DIR}..."
cd ${TARGET_DIR}
wget https://bitbucket.org/genomicepidemiology/plasmidfinder_db/get/2.1.tar.gz
tar -xvf 2.1.tar.gz --strip-components 1
rm *.tar.gz
python INSTALL.py

echo "PlasmidFinder 2.1 database is downloaded."

exit 0
