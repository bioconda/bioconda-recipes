#!/bin/bash

mkdir -p ${PREFIX}/bin

chmod +x serotypefinder.py
cp serotypefinder.py ${PREFIX}/bin/serotypefinder

# create folder for database download
target=${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}
mkdir -p ${target}/db/
touch ${target}/db/.empty

# copy script to download database
cp ${RECIPE_DIR}/download-db.sh ${PREFIX}/bin
chmod +x ${PREFIX}/bin/download-db.sh

# copy script to download database
chmod +x ${RECIPE_DIR}/update-serotypefinder-db.sh
cp ${RECIPE_DIR}/update-serotypefinder-db.sh ${PREFIX}/bin/update-serotypefinder-db

# set SEROTYPEFINDER_DB variable on env activation
mkdir -p ${PREFIX}/etc/conda/activate.d ${PREFIX}/etc/conda/deactivate.d
cat <<EOF >> ${PREFIX}/etc/conda/activate.d/serotypefinder.sh
export SEROTYPEFINDER_DB=${target}/db/
EOF

cat <<EOF >> ${PREFIX}/etc/conda/deactivate.d/serotypefinder.sh
unset SEROTYPEFINDER_DB
EOF
