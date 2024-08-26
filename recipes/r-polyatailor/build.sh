#!/bin/bash


$R -e "devtools::install_github('BMILAB/PolyAtailor')"
$R CMD INSTALL --build .