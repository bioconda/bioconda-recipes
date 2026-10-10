#!/bin/bash

mkdir -p "${PREFIX}/bin"

# Update default DB location
PLASMIDFINDER_DB="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}/database"
mkdir -p "${PLASMIDFINDER_DB}"

${PYTHON} -m pip install . --no-build-isolation --no-deps --no-cache-dir -vvv

PLASMID_DB="${PLASMIDFINDER_DB}"
TARGET_DIR="${PLASMIDFINDER_DB}"

echo "Downloading PlasmidFinder 3.0.3 database to ${TARGET_DIR}..."
cd ${TARGET_DIR}
wget https://bitbucket.org/genomicepidemiology/plasmidfinder_db/get/plasmidfinder-3.0.3.tar.gz
tar -xvf plasmidfinder-3.0.3.tar.gz --strip-components 1
rm -f *.tar.gz

# Install PlasmidFinder database. NOTE that KMA needs to have been installed for the following comand.
python ./INSTALL.py

# set PLASMID_DB variable on env activation
mkdir -p ${PREFIX}/etc/conda/activate.d ${PREFIX}/etc/conda/deactivate.d
cat <<EOF >> ${PREFIX}/etc/conda/activate.d/plasmidfinder.sh
export PLASMID_DB="${PLASMIDFINDER_DB}"
EOF

cat <<EOF >> ${PREFIX}/etc/conda/deactivate.d/plasmidfinder.sh
unset PLASMID_DB
EOF
