#! /bin/bash

$PYTHON -m pip install . --ignore-installed --no-deps -vv

# Add default databases
SPATYPER_SHARE="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"
mkdir -p ${SPATYPER_SHARE}
chmod 755 download-spatypes.sh
./download-spatypes.sh ${SPATYPER_SHARE}
mv download-spaypes.sh ${PREFIX}/bin

# Setup the spaTyper env variables
mkdir -p ${PREFIX}/etc/conda/activate.d ${PREFIX}/etc/conda/deactivate.d
echo "export SPATYPER_SHARE=${SPATYPER_SHARE}" > ${PREFIX}/etc/conda/activate.d/spatyper.sh
chmod a+x ${PREFIX}/etc/conda/activate.d/spatyper.sh

# Unset them
echo "unset SPATYPER_SHARE" > ${PREFIX}/etc/conda/deactivate.d/spatyper.sh
chmod a+x ${PREFIX}/etc/conda/deactivate.d/spatyper.sh
