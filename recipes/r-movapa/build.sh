#!/bin/bash

export DISABLE_AUTOBREW=1
$R -e "devtools::install_github('BMILAB/movAPA')"
$R CMD INSTALL --build .