#!/usr/bin/env bash

echo "Downloading ResFinder databases to ${RESFINDER_DB}..."

# download ResFinder database
mkdir resfinder_db
cd resfinder_db
wget https://bitbucket.org/genomicepidemiology/resfinder_db/get/master.tar.gz
tar -xvf master.tar.gz --strip-components 1

echo "Installing the ResFinder database with KMA"
python INSTALL.py
cd ..

# download PointFinder database
mkdir pointfinder_db
cd pointfinder_db
wget https://bitbucket.org/genomicepidemiology/pointfinder_db/get/master.tar.gz
tar -xvf master.tar.gz --strip-components 1

echo "Installing the ResFinder database with KMA"
python INSTALL.py
cd ..

echo "ResFinder databases are downloaded."
