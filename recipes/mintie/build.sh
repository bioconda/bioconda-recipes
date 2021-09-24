#!/bin/bash

PACKAGE_HOME="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"
BINARY_HOME=$PREFIX/bin

mkdir -p "${PACKAGE_HOME}"
mkdir -p ${BINARY_HOME}

cp -aR * "${PACKAGE_HOME}/"

SOURCE_FILE=${RECIPE_DIR}/mintie-wrapper.sh
DEST_FILE=${PACKAGE_HOME}/mintie

cp ${SOURCE_FILE} ${DEST_FILE}

chmod +x ${DEST_FILE}

ln -s ${DEST_FILE} ${BINARY_HOME}
