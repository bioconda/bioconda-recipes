#!/bin/bash

# copy main scripts
mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/etc
mkdir -p ${PREFIX}/doc
chmod +x bin/*.py
cp bin/* ${PREFIX}/bin/
cp etc/configuration.cfg ${PREFIX}/etc/
cp doc/* ${PREFIX}/doc/

# copy script to download database
chmod +x ${RECIPE_DIR}/download-human-db.sh
cp ${RECIPE_DIR}/download-human-db.sh ${PREFIX}/bin

# create folder for database download
target=${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}
mkdir -p ${target}/db/
touch ${target}/db/.empty

# set FC DB PATH variable on env activation
mkdir -p ${PREFIX}/etc/conda/activate.d ${PREFIX}/etc/conda/deactivate.d
cat <<EOF >> ${PREFIX}/etc/conda/activate.d/fusioncatcher.sh
export FC_DB_PATH=${target}/db/
EOF

cat <<EOF >> ${PREFIX}/etc/conda/deactivate.d/fusioncatcher.sh
unset FC_DB_PATH
EOF
