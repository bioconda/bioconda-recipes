#!/usr/bin/env bash
set -eux

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

# Patch the shebang in EGAP so that it uses python3.
sed -i '1s|^#!/usr/bin/env python$|#!/usr/bin/env python3|' "${PREFIX}/bin/EGAP"
