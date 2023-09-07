#! /bin/bash
TITAN="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"
mkdir -p $PREFIX/bin ${TITAN}

chmod 755 bin/*
cp -f bin/* $PREFIX/bin/

mv conf/ tasks/ workflows/ ${TITAN}

# Setup the VADR env variables
mkdir -p ${PREFIX}/etc/conda/activate.d ${PREFIX}/etc/conda/deactivate.d
echo "export TITAN_GC_VERSION=${PKG_VERSION}" > ${PREFIX}/etc/conda/activate.d//titan-gc.sh
chmod a+x ${PREFIX}/etc/conda/activate.d/titan-gc.sh

# Unset them
echo "unset TITAN_GC_VERSION" > ${PREFIX}/etc/conda/deactivate.d//titan-gc.sh
chmod a+x ${PREFIX}/etc/conda/deactivate.d//titan-gc.sh
