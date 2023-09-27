#!/bin/bash

mkdir -p ${PREFIX}/bin

# Harpy executable
#cp harpy ${PREFIX}/bin/

# build harpy
${PREFIX}/bin/python -m pip install . --ignore-installed --no-deps -vv

# rules
cp rules/*.smk ${PREFIX}/bin/

# associated scripts
chmod +x utilities/*
cp utilities/* ${PREFIX}/bin/

# reports
cp reports/*.Rmd ${PREFIX}/bin/