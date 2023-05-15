#! /usr/bin/env bash

# create bin folder if it doesn't exist
mkdir -p $CONDA_PREFIX/bin

# build and install ema
git clone --recursive https://github.com/EdHarry/ema.git
cd ema 
git submodule update --remote
make
chmod +x ema
cp ema $CONDA_PREFIX/bin/ema-h
cd ..

# Harpy executable
chmod +x harpy
cp harpy $CONDA_PREFIX/bin/

# rules
cp rules/*.smk $CONDA_PREFIX/bin/

# associated scripts
chmod +x utilities/*.{py,R,pl}
cp utilities/*.{py,R,pl} $CONDA_PREFIX/bin/

# reports
chmod +x reports/*.Rmd
cp reports/*.Rmd $CONDA_PREFIX/bin/