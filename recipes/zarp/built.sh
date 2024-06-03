#!/bin/bash

# Install the package
$PYTHON -m pip install . -vv

# Manually copy the data file to the site-packages directory
mkdir -p $SP_DIR/data
cp data/genome_assemblies.csv $SP_DIR/data/