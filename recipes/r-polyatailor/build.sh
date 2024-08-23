#!/bin/bash


$R -e "devtools::install_github('XHWUlab/PolyAtailor')"
$R CMD INSTALL --build .