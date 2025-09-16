#!/bin/bash
$R CMD INSTALL --build .

mkdir -p ${PREFIX}/bin
cp ${SRC_DIR}/inst/cli/linxreport.R ${PREFIX}/bin
chmod +x ${PREFIX}/bin/linxreport.R
