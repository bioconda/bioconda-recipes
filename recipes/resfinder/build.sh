#!/bin/bash

mkdir -p ${PREFIX}/bin

cp *.py ${PREFIX}/bin
chmod +x ${PREFIX}/bin/*.py
cp -r cge/ ${PREFIX}/bin/

# create folder for database download
target=${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}
mkdir -p ${target}/db/
touch ${target}/db/.empty

# copy script to download database
cp ${RECIPE_DIR}/download-db.sh ${PREFIX}/bin
chmod +x ${PREFIX}/bin/download-db.sh

# set RESFINDER_DB variable on env activation
mkdir -p ${PREFIX}/etc/conda/activate.d ${PREFIX}/etc/conda/deactivate.d
cat <<EOF >> ${PREFIX}/etc/conda/activate.d/resfinder.sh
export RESFINDER_DB=${target}/db/
EOF

cat <<EOF >> ${PREFIX}/etc/conda/deactivate.d/resfinder.sh
unset RESFINDER_DB
EOF
