#!/usr/bin/env bash

echo "Downloading KmerFinder database to ${KmerFinder_DB}..."

cd ${KmerFinder_DB}
# download kmerfinder database
git clone https://git@bitbucket.org/genomicepidemiology/kmerfinder_db.git
cd kmerfinder_db
bash INSTALL.py ${KmerFinder_DB} all
cd ..

echo "KmerFinder database is downloaded."

exit 0