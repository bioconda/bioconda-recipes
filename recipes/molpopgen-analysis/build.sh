#!/bin/bash

CXXFLAGS="-O3 -DNDEBUG" CPPFLAGS="-I$PREFIX/include $CPPFLAGS" LDFLAGS="-L$PREFIX/lib -Wl,-rpath,$PREFIX/lib $LDFLAGS" ./configure --prefix=$PREFIX
make
make install

mkdir -p $PREFIX/etc/conda/activate.d/
echo "#!/bin/bash
echo '
/!\ Warning/!\\

DO NOT USE molpopgen-analysis IN NGS STUDIES.

Molpopgen-analysis is a RETIRED package for the (pre-NGS-era) analysis of population-genetic data.
These programs were written with high-quality data in mind (e.g. double-pass Sanger sequencing of PCR amplicons).
Unless you work with Sanger data, RESULTS WILL BE WRONG.

Please check https://github.com/molpopgen/analysis for details.

/!\ Warning/!\\

'" > ${PREFIX}/etc/conda/activate.d/molpopgen-analysis-warning.sh
