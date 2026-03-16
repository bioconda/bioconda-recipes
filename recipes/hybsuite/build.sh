#!/bin/bash
set -eu

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/share/${PKG_NAME}/bin
mkdir -p $PREFIX/share/${PKG_NAME}/config
mkdir -p $PREFIX/share/${PKG_NAME}/dependencies

# Copy script files
cp bin/HybSuite.sh $PREFIX/bin/hybsuite
cp -r bin/*.py $PREFIX/share/${PKG_NAME}/bin/
cp -r bin/*.R $PREFIX/share/${PKG_NAME}/bin/
cp -r config/* $PREFIX/share/${PKG_NAME}/config/
cp -r dependencies/* $PREFIX/share/${PKG_NAME}/dependencies/

# Set execute permissions
chmod +x $PREFIX/bin/hybsuite
chmod -R 755 $PREFIX/share/${PKG_NAME}/

