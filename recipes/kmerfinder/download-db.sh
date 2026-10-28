#!/usr/bin/env bash

echo "Downloading KmerFinder database to ${KmerFinder_DB}..."

cd ${KmerFinder_DB}
# download kmerfinder database
wget -c https://cge.food.dtu.dk/services/KmerFinder/etc/kmerfinder_db.tar.gz -O - | tar -xz
cd ..

echo "KmerFinder database is downloaded."

exit 0
