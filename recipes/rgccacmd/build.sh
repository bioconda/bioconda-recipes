#!/bin/bash
cp -r ${SRC_DIR}/R ${PREFIX}
#mkdir -p ${PREFIX}/inst
#wget -O ${PREFIX}/inst/launcher.R https://raw.githubusercontent.com/BrainAndSpineInstitute/rgcca_ui/master/inst/launcher.R
$R CMD INSTALL .
