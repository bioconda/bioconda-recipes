#!/usr/bin/env bash
set -eux

# Install runner package using pip
pip install ./runner-0.0.0.tar.gz

# Build and install Ratatosk
tar -xzf Ratatosk-0.9.0.tar.gz
cd Ratatosk-0.9.0
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j 4
cd ../..

# Copy EGAP.py to the conda prefix's bin directory and make it executable
mkdir -p "${PREFIX}/bin"
cp EGAP.py "${PREFIX}/bin/EGAP"
chmod +x "${PREFIX}/bin/EGAP"