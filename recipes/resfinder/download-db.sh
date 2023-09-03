#!/usr/bin/env bash

echo "Downloading ResFinder databases to ${RESFINDER_DB}..."

cd ${RESFINDER_DB}
# download ResFinder database
git clone https://git@bitbucket.org/genomicepidemiology/resfinder_db.git db_resfinder
cd db_resfinder
python INSTALL.py
cd ..
# download PointFinder database
git clone https://git@bitbucket.org/genomicepidemiology/pointfinder_db.git db_pointfinder
cd db_pointfinder
python INSTALL.py
cd ..

echo "ResFinder databases are downloaded."

exit 0
