#!/usr/bin/env bash

echo "Downloading pMLST database to ${PMLST_DB}..."

cd ${PMLST_DB}
git clone https://bitbucket.org/genomicepidemiology/pmlst_db.git
mv pmlst_db/* .
rm -rf pmlst_db/
pMLST_DB=$(pwd)
# Install pMLST database with executable kma_index program
python INSTALL.py kma_index

echo "pMLST database is downloaded."

exit 0
