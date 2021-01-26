#!/bin/bash

set -eu -o pipefail

PACKAGE_HOME="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"
mkdir -p "${PREFIX}/bin"
mkdir -p "${PACKAGE_HOME}"

cp -R dist/* "${PACKAGE_HOME}/"
cp "${RECIPE_DIR}/pantools.py" "${PACKAGE_HOME}/pantools.py"

ln -s "${PACKAGE_HOME}/pantools.py" "${PREFIX}/bin/pantools"
chmod 0755 "${PREFIX}/bin/pantools"
