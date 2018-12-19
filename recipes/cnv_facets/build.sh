#!/bin/bash

set -e

FACETS_GIT_REF=`grep -P ' *^FACETS_REF' install/install_pkgs.R \
| sed 's/ //g; s/<-//; s/=//;' \
| tr "'" '"' \
| sed 's/FACETS_REF"//; s/".*//'`

$R -e "devtools::install_github('mskcc/facets', ref= '$FACETS_GIT_REF', lib= NULL, repos= 'https://cran.r-project.org')"

$R -e 'install.packages("argparse", lib= NULL, repos= "https://cran.r-project.org")'

mkdir -p $PREFIX/bin
chmod a+x bin/cnv_facets.R
cp bin/cnv_facets.R $PREFIX/bin/
