#!/bin/bash
#
# CONDA build script variables 
# 
# $PREFIX The install prefix
# $PKG_NAME The name of the package
# $PKG_VERSION The version of the package
# $PKG_BUILDNUM The build number of the package
#
set -eu -o pipefail

cd t_coffee_source
make CC="$CXX" CFLAGS="$CFLAGS"

SHARE_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"
# install t_coffee binary in SHARE_DIR
mkdir -p "${SHARE_DIR}/bin"
cp t_coffee "${SHARE_DIR}/bin/"
# install mcoffee data files
cd ..
mv mcoffee/ "$SHARE_DIR/"
# install t_coffer wrapper
mkdir -p "${PREFIX}/bin"
sed -e "s|CHANGEME|${SHARE_DIR}|" "$RECIPE_DIR/t_coffee.sh" > "${PREFIX}/bin/t_coffee"
