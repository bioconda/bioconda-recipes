#!/bin/bash

mkdir -p ${PREFIX}/bin

cp VIBRANT_run.py ${PREFIX}/bin
cp scripts/* ${PREFIX}/bin

chmod +x ${PREFIX}/bin/*

# copy script to download database
cp ${RECIPE_DIR}/download-db.sh ${PREFIX}/bin
chmod +x ${PREFIX}/bin/download-db.sh

# create folder for database download
target=${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}
mkdir -p ${target}
cp -r databases ${target}
cp -r files ${target}
chmod +x ${target}/databases/VIBRANT_setup.py

# set VIBRANT DB PATH variable on env activation
mkdir -p ${PREFIX}/etc/conda/activate.d ${PREFIX}/etc/conda/deactivate.d
cat <<EOF >> ${PREFIX}/etc/conda/activate.d/vibrant.sh
export VIBRANT_DATA_PATH=${target}
EOF

cat <<EOF >> ${PREFIX}/etc/conda/deactivate.d/vibrant.sh
unset VIBRANT_DATA_PATH
EOF
