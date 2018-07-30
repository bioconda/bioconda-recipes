#!/bin/bash

pip install -r requirements.txt
mkdir -p slamdunk/plot/Rslamdunk
export R_LIBS_SITE=${PREFIX}/slamdunk/plot/Rslamdunk
echo $R_LIBS_SITE
echo "PREFIX"
echo $PREFIX
ls $PREFIX
echo "RECIPE_DIR"
echo $RECIPE_DIR
echo "SP_DIR"
echo $SP_DIR
ls $SP_DIR
echo "SRC_DIR"
echo $SRC_DIR
ls $SRC_DIR
#R --vanilla -e 'libLoc = .libPaths()[grep("Rslamdunk",.libPaths())]; source("${PREFIX}/slamdunk/plot/checkLibraries.R"); checkLib(libLoc)'
cd slamdunk/contrib
./build-ngm.sh
./build-varscan.sh
./build-samtools.sh
./build-rnaseqreadsimulator.sh

