#!/usr/bin/env bash

echo "Downloading SerotypeFinder database to ${SEROTYPEFINDER_DB}..."

# Grab latest database
# The SerotypeFinder database is not tagged and versioned, but it's also not updated
# very often (~7 commits in 5 years). ada62c62a7fa74032448bb2273d1f7045c59fdda is the
# latest commit as of 2022/05/16. A script is provided to allow users to update in the
# event an update is made.

cd ${SEROTYPEFINDER_DB}
# download SerotypeFinder database
git clone https://bitbucket.org/genomicepidemiology/serotypefinder_db.git db_serotypefinder
cd db_serotypefinder
python3 INSTALL.py
git rev-parse HEAD > serotypefinder-db-commit.txt
cd ..

echo "SerotypeFinder database is downloaded."

exit 0
