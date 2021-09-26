#!/bin/bash

package_home="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"
BINARY_HOME=$PREFIX/bin

mkdir -p "${package_home}"
mkdir -p ${BINARY_HOME}

cp -aR * "${package_home}/"

SOURCE_FILE=${RECIPE_DIR}/mintie-wrapper.sh
DEST_FILE=${package_home}/mintie

sed \
    's|\$PACKAGE_HOME|'"${package_home}"'|g' \
    "${SOURCE_FILE}" \
    > "${DEST_FILE}"

#cp ${SOURCE_FILE} ${DEST_FILE}

chmod +x ${DEST_FILE}

ln -s ${DEST_FILE} ${BINARY_HOME}
