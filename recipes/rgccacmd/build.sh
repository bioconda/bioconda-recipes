#!/bin/bash
cp -r ${SRC_DIR}/R ${PREFIX}
mkdir -p ${PREFIX}/inst
wget -O ${PREFIX}/inst/launcher.R https://raw.githubusercontent.com/BrainAndSpineInstitute/rgcca_ui/master/inst/launcher.R
if [[ $target_platform =~ linux.* ]] || [[ $target_platform == win-32 ]]; then
  $R CMD INSTALL --build .
else
  mkdir -p $PREFIX/lib/R/library/rgcca
  mv * $PREFIX/lib/R/library/rgcca
fi