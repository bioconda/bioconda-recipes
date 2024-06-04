#!/bin/bash

# Install the package
$PYTHON -m pip install . --no-deps --no-build-isolation -vvv

# Manually copy the data file to the site-packages directory
mkdir -p $PREFIX/lib/python${PY_VER}/site-packages/zarp/data
cp data/genome_assemblies.csv $PREFIX/lib/python${PY_VER}/site-packages/zarp/data/
