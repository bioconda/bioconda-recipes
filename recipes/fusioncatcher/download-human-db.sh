#!/usr/bin/env bash

echo "Downloading Human Ensembl v95 database to ${FC_DB_PATH}/current/..."

# Direct download:
cd ${FC_DB_PATH}
rm -rf human_v98.tar.gz.*
wget http://sourceforge.net/projects/fusioncatcher/files/data/human_v98.tar.gz.aa
wget http://sourceforge.net/projects/fusioncatcher/files/data/human_v98.tar.gz.ab
wget http://sourceforge.net/projects/fusioncatcher/files/data/human_v98.tar.gz.ac
wget http://sourceforge.net/projects/fusioncatcher/files/data/human_v98.tar.gz.ad
cat human_v98.tar.gz.* | tar xz
ln -s human_v98 current

echo "Human Ensembl v98 database is downloaded."

exit 0
