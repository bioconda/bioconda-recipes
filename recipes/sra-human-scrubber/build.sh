#!/bin/bash

# Setup shared directory
SHARE_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"
mkdir -p ${SHARE_DIR}/data
cp -r ./test ${SHARE_DIR}/
touch ${SHARE_DIR}/data/sra-human-scrubber-placeholder.txt

# Replace with share directory path
sed -i "s=BIOCONDA_SED_REPLACE=$SHARE_DIR=" init_db.sh
sed -i "s=BIOCONDA_SED_REPLACE=$SHARE_DIR=" scripts/scrub.sh

# Add scripts
mkdir -p ${PREFIX}/bin
chmod 755 bin/*
cp bin/* ${PREFIX}/bin
chmod 755 scripts/*
cp scripts/* ${PREFIX}/bin
chmod 755 init_db.sh
cp init_db.sh ${PREFIX}/bin
