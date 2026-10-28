#!/bin/env bash

set -euo

PACKAGE_HOME=${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}
mkdir -p ${PACKAGE_HOME}
cp -r ./* ${PACKAGE_HOME}

# Make TE-Aid executable available
mkdir -p ${PREFIX}/bin
chmod +x ${PACKAGE_HOME}/TE-Aid
ln -s ${PACKAGE_HOME}/TE-Aid ${PREFIX}/bin
