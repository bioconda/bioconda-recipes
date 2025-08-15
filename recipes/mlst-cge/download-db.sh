#!/usr/bin/env bash

echo "Downloading MLST database to ${MLST_DB}..."

cd ${MLST_DB}
# download MLST database
git clone https://git@bitbucket.org/genomicepidemiology/mlst_db.git
cd mlst_db
python INSTALL.py
cd ..

echo "MLST database is downloaded."

exit 0
