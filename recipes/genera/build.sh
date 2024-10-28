#!/bin/bash

# Exit on any error
set -ex

# Ensure all main scripts are executable
chmod +x genEra Erassignment hmmEra tree2ncbitax FASTSTEP3R test_installation.sh

# Clone the secondary repository and move the main script
git clone https://github.com/caraweisman/abSENSE.git
mv abSENSE/Run_abSENSE.py .
chmod +x Run_abSENSE.py

# Define the Conda binary path
CONDABIN="${PREFIX}/bin"

# Ensure the directory exists
mkdir -p "$CONDABIN"


# Move executables to the Conda binary directory
mv genEra "$CONDABIN"
mv Erassignment "$CONDABIN"
mv Run_abSENSE.py "$CONDABIN"
mv hmmEra "$CONDABIN"
mv tree2ncbitax "$CONDABIN"
mv FASTSTEP3R "$CONDABIN"
mv test_installation.sh "$CONDABIN"

echo "Installation complete. Executables have been moved to ${CONDABIN}."
