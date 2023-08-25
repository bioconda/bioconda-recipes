#!/bin/bash

mkdir -p ${PREFIX}/bin

# Harpy executable
#cp harpy ${PREFIX}/bin/

# build harpy
python -m pip install --no-deps .

# rules
cp rules/*.smk ${PREFIX}/bin/

# associated scripts
cp utilities/*.{py,R,pl} ${PREFIX}/bin/

# reports
cp reports/*.Rmd ${PREFIX}/bin/