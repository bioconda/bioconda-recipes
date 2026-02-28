#!/bin/bash

# copy setup.py to package directory
cp ${RECIPE_DIR}/setup.py ${SRC_DIR}/setup.py
python -m pip install . --no-deps --ignore-installed --no-cache-dir -vvv

# create directory for data
OUT=${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}
mkdir -p ${OUT}/data
cp -r ./databases/* ${OUT}/data/ 

# copy script to download database
cp ${RECIPE_DIR}/create-db-indices.sh ${PREFIX}/bin
chmod +x ${PREFIX}/bin/create-db-indices.sh

# set database variable on env activation
mkdir -p ${PREFIX}/etc/conda/activate.d ${PREFIX}/etc/conda/deactivate.d
cat <<EOF >> ${PREFIX}/etc/conda/activate.d/transcriptm.sh
export TRANSCRIPTM_DATABASE=${OUT}/data/
EOF

cat <<EOF >> ${PREFIX}/etc/conda/deactivate.d/transcriptm.sh
unset TRANSCRIPTM_DATABASE
EOF
