#!/bin/bash
set -eu

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/share/${PKG_NAME}/bin
mkdir -p $PREFIX/share/${PKG_NAME}/config
mkdir -p $PREFIX/share/${PKG_NAME}/dependencies

# main script
cp $SRC_DIR/bin/HybSuite.sh $PREFIX/bin/hybsuite

# other scripts
cp -r $SRC_DIR/bin/*.py $PREFIX/share/${PKG_NAME}/bin/ || true
cp -r $SRC_DIR/bin/*.R $PREFIX/share/${PKG_NAME}/bin/ || true

cp -r $SRC_DIR/config/* $PREFIX/share/${PKG_NAME}/config/
cp -r $SRC_DIR/dependencies/* $PREFIX/share/${PKG_NAME}/dependencies/

chmod +x $PREFIX/bin/hybsuite
chmod -R 755 $PREFIX/share/${PKG_NAME}/

