#!/bin/bash

# Add scripts
mkdir -p ${PREFIX}/bin
chmod 755 bin/*
cp bin/* ${PREFIX}/bin
chmod 755 scripts/*
cp scripts/* ${PREFIX}/bin
chmod 755 init_db.sh
cp init_db.sh ${PREFIX}/bin

# Setup shared directory
SHARE_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"
mkdir -p ${SHARE_DIR}/data
cp -r ./test ${SHARE_DIR}/
touch ${SHARE_DIR}/data/sra-human-scrubber-placeholder.txt

# Setup the VADR env variables
mkdir -p ${PREFIX}/etc/conda/activate.d ${PREFIX}/etc/conda/deactivate.d
echo "export SCRUBBER_ROOT=${PREFIX}" > ${PREFIX}/etc/conda/activate.d/sra-human-scrubber.sh
echo "export SCRUBBER_SHARE=${SHARE_DIR}" >> ${PREFIX}/etc/conda/activate.d/sra-human-scrubber.sh
chmod a+x ${PREFIX}/etc/conda/activate.d/sra-human-scrubber.sh

# Unset them
echo "unset SCRUBBER_ROOT" > ${PREFIX}/etc/conda/deactivate.d/sra-human-scrubber.sh
echo "unset SCRUBBER_SHARE" >> ${PREFIX}/etc/conda/deactivate.d/sra-human-scrubber.sh
chmod a+x ${PREFIX}/etc/conda/deactivate.d/sra-human-scrubber.sh
