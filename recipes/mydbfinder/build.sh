#!/bin/bash

mkdir -p ${PREFIX}/bin

cp *.py ${PREFIX}/bin
chmod +x ${PREFIX}/bin/*.py

# create folder for database download
target=${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}
mkdir -p ${target}/db/
touch ${target}/db/.empty

# copy script to download database
cp ${RECIPE_DIR}/download-db.sh ${PREFIX}/bin
chmod +x ${PREFIX}/bin/download-db.sh

# set MyDbFinder_DB variable on env activation
mkdir -p ${PREFIX}/etc/conda/activate.d ${PREFIX}/etc/conda/deactivate.d
cat <<EOF >> ${PREFIX}/etc/conda/activate.d/mydbfinder.sh
export MyDbFinder_DB=${target}/db/
EOF

cat <<EOF >> ${PREFIX}/etc/conda/deactivate.d/mydbfinder.sh
unset MyDbFinder_DB
EOF
