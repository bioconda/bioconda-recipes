#!/bin/bash

#python setup.py install --single-version-externally-managed --record=record.txt
mkdir -p slamdunk/plot/Rslamdunk
export R_LIBS_SITE=slamdunk/plot/Rslamdunk
#$R --vanilla -e 'libLoc = .libPaths()[grep("Rslamdunk",.libPaths())]; source("slamdunk/plot/checkLibraries.R"); checkLib(libLoc)'
cd slamdunk/contrib
./build-ngm.sh
./build-varscan.sh
./build-samtools.sh
./build-rnaseqreadsimulator.sh