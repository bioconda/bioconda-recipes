#!/usr/bin/env bash

echo "Downloading Human Ensembl v95 database to ${FC_DB_PATH}/current/..."

# Direct download:
cd ${FC_DB_PATH}
rm -rf human_v95.tar.gz.*
wget http://sourceforge.net/projects/fusioncatcher/files/data/human_v95.tar.gz.aa
wget http://sourceforge.net/projects/fusioncatcher/files/data/human_v95.tar.gz.ab
wget http://sourceforge.net/projects/fusioncatcher/files/data/human_v95.tar.gz.ac
wget http://sourceforge.net/projects/fusioncatcher/files/data/human_v95.tar.gz.ad
cat human_v95.tar.gz.* | tar xz
ln -s human_v95 current

echo "Human Ensembl v95 database is downloaded."

exit 0
