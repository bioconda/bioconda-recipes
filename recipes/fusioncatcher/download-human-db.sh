#!/usr/bin/env bash

# FusionCatcher v1.33 uses Human Ensembl v102
echo "Downloading Human Ensembl v102 database to ${FC_DB_PATH}/current/..."

# Direct download:
cd ${FC_DB_PATH}
rm -rf human*.tar.gz.*

wget --no-check-certificate http://sourceforge.net/projects/fusioncatcher/files/data/human_v102.tar.gz.aa -O human_v102.tar.gz.aa
wget --no-check-certificate http://sourceforge.net/projects/fusioncatcher/files/data/human_v102.tar.gz.ab -O human_v102.tar.gz.ab
wget --no-check-certificate http://sourceforge.net/projects/fusioncatcher/files/data/human_v102.tar.gz.ac -O human_v102.tar.gz.ac
wget --no-check-certificate http://sourceforge.net/projects/fusioncatcher/files/data/human_v102.tar.gz.ad -O human_v102.tar.gz.ad

cat human_v102.tar.gz.* | tar xz
ln -s human_v102 current

echo "Human Ensembl v102 database is downloaded."

exit 0
