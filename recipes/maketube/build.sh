#!/bin/bash

R -e "install.packages('jackalope', repo='https://pbil.univ-lyon1.fr/CRAN/')"


mkdir -p "$PREFIX/bin/"

cp "maketube.R" "$PREFIX/bin/maketube.R"
cp "vcf2metrics.py" "$PREFIX/bin/vcf2metrics.py"

