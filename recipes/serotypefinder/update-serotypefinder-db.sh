#!/usr/bin/env bash
# The SerotypeFinder database is not tagged and versioned, but it's also not updated 
# very often. This is script provides the user a method for pulling the lastest
# database version while also tracking the commit version.
cd ${SEROTYPEFINDER_DB}
CURENTCOMMIT=""
# Get current version
if [ -s "serotypefinder-db-commit.txt" ]; then
    # DB exists, read the hash
    CURENTCOMMIT=$(head -n1 serotypefinder-db-commit.txt)
fi

LATESTCOMMIT=$(git ls-remote https://bitbucket.org/genomicepidemiology/serotypefinder_db.git | grep master | awk '{print $1}')
if [ "${LATESTCOMMIT}" == "${CURENTCOMMIT}" ]; then
    echo "Current SerotypeFinder database is already up to date"
else
    echo "Downloading latest SerotypeFinder database to ${SEROTYPEFINDER_DB}..."
    echo ${LATESTCOMMIT} > serotypefinder-db-commit.txt
    git pull
    python INSTALL.py
    echo "SerotypeFinder database is updated to commit ${LATESTCOMMIT}"
fi

exit 0
