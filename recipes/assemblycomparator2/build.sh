#!/bin/bash -euo

mkdir -p ${PREFIX}/bin

export PACKAGE_HOME="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"

# First we put the necessary files in into the conda prefix/share directory:
mkdir -p "${PACKAGE_HOME}"
chmod 755 asscom2
cp -f asscom2 LICENSE "${PACKAGE_HOME}"
cp -rf config docs dynamic_report profile resources tests workflow "${PACKAGE_HOME}"

# This is the binary that we wish to be able to run.
ln -sf ${PACKAGE_HOME}/asscom2 ${PREFIX}/bin/asscom2
