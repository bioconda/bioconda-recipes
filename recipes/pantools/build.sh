#!/bin/bash

set -eu -o pipefail

PACKAGE_HOME="${PREFIX}/share/${PKG_NAME}"
mkdir -p "${PREFIX}/bin"
mkdir -p "${PACKAGE_HOME}"

mvn package -DskipTests=true

cp -R target/* "${PACKAGE_HOME}/"
cp "${RECIPE_DIR}/pantools.py" ${PREFIX}/bin/pantools
chmod 0755 ${PREFIX}/bin/pantools
