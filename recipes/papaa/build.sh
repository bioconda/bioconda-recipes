#!/bin/bash

cp -r $SRC_DIR ${PREFIX}/papaa
mkdir -p "${PREFIX}/bin"
ln -s ${PREFIX}/papaa/python/scripts/*.py ${PREFIX}/bin/
ln -s ${PREFIX}/papaa/r/scripts/*.R ${PREFIX}/bin/

chmod +x ${PREFIX}/papaa/python/scripts/*.py
chmod +x ${PREFIX}/papaa/r/scripts/*.R

