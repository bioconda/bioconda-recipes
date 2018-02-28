#!/bin/bash

cat <<EOF >> ${PREFIX}/.messages.txt
/!\ Warning/!\\

DO NOT USE THIS PACKAGE IN NGS STUDIES.

This is a RETIRED package for the (pre-NGS-era) analysis of population-genetic data.
These programs were written with high-quality data in mind (e.g. double-pass Sanger sequencing of PCR amplicons).
Unless you work with Sanger data, RESULTS WILL BE WRONG.

Please check https://github.com/molpopgen/analysis for more details.

/!\ Warning/!\\
EOF