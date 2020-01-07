#!/usr/bin/env bash

# FusionCatcher v1.20 uses Human Ensembl v98
echo "Downloading Human Ensembl v98 database to ${FC_DB_PATH}/current/..."

# Direct download:
cd ${FC_DB_PATH}
rm -rf human*.tar.gz.*

wget --no-check-certificate http://sourceforge.net/projects/fusioncatcher/files/data/human_v98.tar.gz.aa -O human_v98.tar.gz.aa
wget --no-check-certificate http://sourceforge.net/projects/fusioncatcher/files/data/human_v98.tar.gz.ab -O human_v98.tar.gz.ab
wget --no-check-certificate http://sourceforge.net/projects/fusioncatcher/files/data/human_v98.tar.gz.ac -O human_v98.tar.gz.ac
wget --no-check-certificate http://sourceforge.net/projects/fusioncatcher/files/data/human_v98.tar.gz.ad -O human_v98.tar.gz.ad

cat human_v98.tar.gz.* | tar xz
ln -s human_v98 current

echo "Human Ensembl v98 database is downloaded."

exit 0
