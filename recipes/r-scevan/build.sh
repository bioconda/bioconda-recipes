#!/bin/bash
R -e "library(devtools)"
R -e "devtools::install_github('miccec/yaGST')"
R -e "devtools::install_github('AntonioDeFalco/SCEVAN')"
