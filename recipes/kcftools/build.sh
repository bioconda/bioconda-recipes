#!/bin/bash
set -euxo pipefail

# create target directories
mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/share/${PKG_NAME}"

# build JAR
mvn package -DskipTests=true

# copy the JAR to share/
cp target/kcftools-${PKG_VERSION}.jar "${PREFIX}/share/${PKG_NAME}/kcftools.jar"

# install the Python wrapper
cp ${RECIPE_DIR}/kcftools.py ${PREFIX}/bin/kcftools

# set executable permissions
chmod +x "${PREFIX}/bin/kcftools"
#EOF
