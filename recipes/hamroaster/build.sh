#!/bin/bash

mkdir -p $PREFIX/bin
chmod 755 hAMRoaster.py
cp -f hAMRoaster.py $PREFIX/bin/hAMRoaster

# Setup shared directory
SHARE_DIR="${PREFIX}/share/${PKG_NAME}"
mkdir -p ${SHARE_DIR}/db_files
cp db_files/* ${SHARE_DIR}/db_files/
