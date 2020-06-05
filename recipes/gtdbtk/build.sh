#!/bin/bash

# install python libraries
python -m pip install . --no-deps --ignore-installed --no-cache-dir -vvv

# copy script to download database
chmod +x ${RECIPE_DIR}/download-db.sh
cp ${RECIPE_DIR}/download-db.sh ${PREFIX}/bin

# create folder for database download
target=${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}
mkdir -p ${target}/db/
touch ${target}/db/.empty

# set GTDBTK DB PATH variable on env activation
mkdir -p ${PREFIX}/etc/conda/activate.d ${PREFIX}/etc/conda/deactivate.d
cat <<EOF >> ${PREFIX}/etc/conda/activate.d/gtdbtk.sh
export GTDBTK_DATA_PATH=${target}/db/
EOF

cat <<EOF >> ${PREFIX}/etc/conda/deactivate.d/gtdbtk.sh
unset GTDBTK_DATA_PATH
EOF
