#!/bin/bash
mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/share/bioconductor-data-packages
cp ${SRC_DIR}/installBiocDataPackage.sh  ${PREFIX}/bin
cp ${SRC_DIR}/dataURLs.json ${PREFIX}/share/bioconductor-data-packages/dataURLs.json
