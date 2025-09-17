#!/bin/bash

$PYTHON -m pip install --no-deps --ignore-installed --no-cache-dir -vv . 

mkdir -p ${PREFIX}/bin

# copy script to download database
chmod +x ${RECIPE_DIR}/download-virulence-db.sh
cp ${RECIPE_DIR}/download-virulence-db.sh ${PREFIX}/bin/download-virulence-db.sh
