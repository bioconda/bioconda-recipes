#!/bin/bash
cp -r ${SRC_DIR}/R ${PREFIX}
mkdir -p inst
touch inst/launcher.R
#wget -O ${PREFIX}/inst/launcher.R https://raw.githubusercontent.com/BrainAndSpineInstitute/rgcca_ui/master/inst/launcher.R
$R CMD INSTALL .
