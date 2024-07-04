#!/bin/bash -euo

# Set up dir
mkdir -p ${PREFIX}/bin
export PACKAGE_HOME="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"

# Copy files
mkdir -p "${PACKAGE_HOME}"
chmod 755 comparem2
cp -f comparem2 LICENSE "${PACKAGE_HOME}"
cp -rf config docs dynamic_report profile resources tests workflow "${PACKAGE_HOME}"

# Make links
ln -sf ${PACKAGE_HOME}/comparem2 ${PREFIX}/bin/comparem2
ln -sf ${PACKAGE_HOME}/comparem2 ${PREFIX}/bin/asscom2 # Legacy
