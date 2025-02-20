#!/bin/bash

# Exit on any error
set -ex

sed -i.bak '1s|^|#!/usr/bin/env python\n|' run_model.py
sed -i.bak '1s|^|#!/usr/bin/env python\n|' utilities.py
sed -i.bak '1s|^|#!/usr/bin/env python\n|' network.py


chmod +x run_model.py utilities.py network.py


# Define the Conda binary path
CONDABIN="${PREFIX}/bin"

# Ensure the directory exists
mkdir -p "$CONDABIN"


# Move executables to the Conda binary directory
mv run_model.py "$CONDABIN"
mv utilities.py "$CONDABIN"
mv network.py "$CONDABIN"
echo "Installation complete. Executables have been moved to ${CONDABIN}."
