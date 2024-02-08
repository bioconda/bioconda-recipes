#! /usr/bin/env bash

mkdir -p ${PREFIX}/bin

# install harpy proper
${PREFIX}/bin/python -m pip install . --no-deps -vv

# rules
cp workflow/rules/*.smk ${PREFIX}/bin/

# associated scripts
chmod +x workflow/scripts/* 
cp workflow/scripts/* ${PREFIX}/bin/

# reports
cp workflow/report/*.Rmd ${PREFIX}/bin/
