#!/usr/bin/env bash

echo "Downloading Human Ensembl v90 database to ${FC_DB_PATH}/current/..."

# Direct download:
cd ${FC_DB_PATH}
rm -rf human_v90.tar.gz.*
wget http://sourceforge.net/projects/fusioncatcher/files/data/human_v90.tar.gz.aa
wget http://sourceforge.net/projects/fusioncatcher/files/data/human_v90.tar.gz.ab
wget http://sourceforge.net/projects/fusioncatcher/files/data/human_v90.tar.gz.ac
wget http://sourceforge.net/projects/fusioncatcher/files/data/human_v90.tar.gz.ad
cat human_v90.tar.gz.* | tar xz
ln -s human_v90 current

echo "Human Ensembl v90 database is downloaded."

exit 0
