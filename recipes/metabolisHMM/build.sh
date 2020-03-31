#!/bin/bash

# Decompress the HMM database
tar zxvf metabolisHMM_markers_v1.9.tgz

# Install python libraries
python3 -m pip install .

# Copy scripts to environment bin/
chmod +x bin/*
cp bin/* ${PREFIX}/bin/

