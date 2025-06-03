#!/bin/bash

# Update default DB location
mkdir -p ${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}
cp -r database ${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}/
SEROBA_DB=${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}/database
sed -i "s=BIOCONDA_SED_REPLACE=$SEROBA_DB=" scripts/seroba

# build seroba
$PYTHON -m pip install . --ignore-installed --no-deps -vv

# Create database with recommended kmer size (k=71)
$PYTHON ${PREFIX}/bin/seroba createDBs ${SEROBA_DB} 71
