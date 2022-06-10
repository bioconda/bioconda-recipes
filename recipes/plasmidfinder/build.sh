#!/bin/bash

# Update default DB location
PLASMIDFINDER_SHARE=${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}
sed -i "s=BIOCONDA_SED_REPLACE=$PLASMIDFINDER_SHARE=" plasmidfinder.py

# Copy plasmidfinder
mkdir -p ${PREFIX}/bin
chmod +x plasmidfinder.py
cp plasmidfinder.py ${PREFIX}/bin/plasmidfinder.py

# copy script to download database
chmod +x ${RECIPE_DIR}/download-db.sh
cp ${RECIPE_DIR}/download-db.sh ${PREFIX}/bin/download-db.sh

# Build database
mkdir -p ${PLASMIDFINDER_SHARE}/database/
${PREFIX}/bin/download-db.sh ${PLASMIDFINDER_SHARE}/database/

# set PLASMID_DB variable on env activation
mkdir -p ${PREFIX}/etc/conda/activate.d ${PREFIX}/etc/conda/deactivate.d
cat <<EOF >> ${PREFIX}/etc/conda/activate.d/plasmidfinder.sh
export PLASMID_DB=${PLASMIDFINDER_SHARE}/database/
EOF

cat <<EOF >> ${PREFIX}/etc/conda/deactivate.d/plasmidfinder.sh
unset PLASMID_DB
EOF
