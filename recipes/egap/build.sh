#!/usr/bin/env bash
set -eux
ls -l ..

# Build and install Ratatosk
cd Ratatosk-0.9.0
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release -DENABLE_AVX2=OFF ..
make -j 4
cd ../..

# Install EGAP: copy EGAP.py to $PREFIX/bin and make it executable.
mkdir -p "${PREFIX}/bin"
cp EGAP.py "${PREFIX}/bin/EGAP"
chmod +x "${PREFIX}/bin/EGAP"
