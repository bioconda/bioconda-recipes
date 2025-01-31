#!/usr/bin/env bash
set -euxo pipefail

# Build purge_dups from source
git clone https://github.com/dfguan/purge_dups.git
cd purge_dups/src
make CC="$CC"
mkdir -p $PREFIX/bin
cp ../bin/* $PREFIX/bin/
cd "$SRC_DIR"

# Build Ratatosk from source
git clone --recursive https://github.com/DecodeGenetics/Ratatosk.git
cd Ratatosk
mkdir -p build && cd build
cmake -DCMAKE_INSTALL_PREFIX="$PREFIX" ..
make
make install
cd "$SRC_DIR"

# Install or copy EGAP main script
chmod +x EGAP.py
mkdir -p $PREFIX/bin
cp EGAP.py $PREFIX/bin/EGAP
