#!/bin/bash

# Exit on any error
set -ex

sed -i.bak '1s|^|#!/usr/bin/env python\n|' Plot_abSENSE.py


chmod +x Run_abSENSE.py Plot_abSENSE.py


# Define the Conda binary path
CONDABIN="${PREFIX}/bin"

# Ensure the directory exists
mkdir -p "$CONDABIN"


# Move executables to the Conda binary directory
mv Run_abSENSE.py "$CONDABIN"
mv Plot_abSENSE.py "$CONDABIN"
echo "Installation complete. Executables have been moved to ${CONDABIN}."
