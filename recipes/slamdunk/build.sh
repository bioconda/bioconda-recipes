#!/bin/bash

pip install -r requirements.txt
mkdir -p ${PREFIX}/slamdunk/plot/Rslamdunk
export R_LIBS_SITE=${PREFIX}/slamdunk/plot/Rslamdunk
R --vanilla -e 'libLoc = .libPaths()[grep("Rslamdunk",.libPaths())]; source("${PREFIX}/slamdunk/plot/checkLibraries.R"); checkLib(libLoc)'
cd ${PREFIX}/slamdunk/contrib
./build-ngm.sh
./build-varscan.sh
./build-samtools.sh
./build-rnaseqreadsimulator.sh

