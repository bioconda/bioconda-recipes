#!/bin/bash
set -ex
mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/share/bioconductor-data-packages
cp ${RECIPE_DIR}/installBiocDataPackage.sh  ${PREFIX}/bin
cp ${RECIPE_DIR}/dataURLs.json ${PREFIX}/share/bioconductor-data-packages/dataURLs.json
