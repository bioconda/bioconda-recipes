#! /bin/bash
THEIACOV="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"
mkdir -p $PREFIX/bin ${THEIACOV}

chmod 755 bin/*
cp -f bin/* $PREFIX/bin/

mv conf/ tasks/ workflows/ ${THEIACOV}

# Setup the TheiaCoV env variables
mkdir -p ${PREFIX}/etc/conda/activate.d ${PREFIX}/etc/conda/deactivate.d
echo "export THEIACOV_GC_VERSION=${PKG_VERSION}" > ${PREFIX}/etc/conda/activate.d/theiacov-gc.sh
chmod a+x ${PREFIX}/etc/conda/activate.d/theiacov-gc.sh

# Unset them
echo "unset THEIACOV_GC_VERSION" > ${PREFIX}/etc/conda/deactivate.d/theiacov-gc.sh
chmod a+x ${PREFIX}/etc/conda/deactivate.d/theiacov-gc.sh
