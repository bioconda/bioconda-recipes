#!/bin/bash

mkdir -p ${PREFIX}/bin

cp misc/ema-h ${PREFIX}/bin

# Harpy executable
cp harpy ${PREFIX}/bin/

# rules
cp rules/*.smk ${PREFIX}/bin/

# associated scripts
cp utilities/*.{py,R,pl} ${PREFIX}/bin/

# reports
cp reports/*.Rmd ${PREFIX}/bin/