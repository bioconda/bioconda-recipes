#!/bin/bash


$R -e "devtools::install_github('BMILAB/movAPA')"
$R CMD INSTALL --build .