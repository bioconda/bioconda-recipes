#!/usr/bin/env bash
set -eux
ls -l ..

# Install the runner package from the tarball that is one level up
pip install ../runner-0.0.0.tar.gz

# Build and install Ratatosk
tar -xzf Ratatosk-0.9.0.tar.gz
cd Ratatosk-0.9.0
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j 4
cd ../..

# Install EGAP: copy EGAP.py to $PREFIX/bin and make it executable
mkdir -p "${PREFIX}/bin"
cp EGAP.py "${PREFIX}/bin/EGAP"
chmod +x "${PREFIX}/bin/EGAP"
