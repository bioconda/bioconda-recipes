#!/usr/bin/env bash

echo "Downloading lastest version of the VirulenceFinder database to current directory..."

mkdir virulencefinder_db
cd virulencefinder_db

wget https://bitbucket.org/genomicepidemiology/virulencefinder_db/get/master.tar.gz
tar -xvf master.tar.gz --strip-components 1

echo "Installing the VirulenceFinder database with KMA"
python INSTALL.py

echo "The VirulenceFinder database has been downloaded and installed."

exit 0