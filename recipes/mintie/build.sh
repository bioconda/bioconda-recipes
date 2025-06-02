#!/bin/bash

PACKAGE_HOME="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"
BINARY_HOME=$PREFIX/bin

mkdir -p ${PACKAGE_HOME}
mkdir -p ${BINARY_HOME}

cp -aR * "${PACKAGE_HOME}/"

WRAPPER=${PACKAGE_HOME}/mintie
TMP_FILE=${PACKAGE_HOME}/mintie.tmp

# insert package home path into wrapper script
sed 's|\$MINTIE_HOME|'"${PACKAGE_HOME}"'|g' \
    ${WRAPPER} > ${TMP_FILE}

mv ${TMP_FILE} ${WRAPPER}
chmod +x ${WRAPPER}

ln -s ${WRAPPER} ${BINARY_HOME}
