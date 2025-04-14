#!/bin/bash

$R -e "remotes::install_version('cghseg',upgrade='never',version='1.0.5',repos='https://cran.uib.no/')"
$R -e "remotes::install_version('cwhmisc',upgrade='never',version='6.6',repos='https://cran.uib.no/')"

cp src/*.pl $PREFIX/bin
cp src/*.R $PREFIX/bin
