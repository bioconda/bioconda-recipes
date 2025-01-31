#!/usr/bin/env bash
set -euxo pipefail

###############################################################################
# 1) Build 'purge_dups' from source, if not already in Bioconda
###############################################################################
git clone https://github.com/dfguan/purge_dups.git
cd purge_dups/src
make
# Copy the resulting binaries into $PREFIX/bin
mkdir -p $PREFIX/bin
cp ../bin/* $PREFIX/bin/
cd "$SRC_DIR"  # Return to the main source directory

###############################################################################
# 2) Build 'Ratatosk' from source, if not already in Bioconda
###############################################################################
git clone --recursive https://github.com/DecodeGenetics/Ratatosk.git
cd Ratatosk
mkdir -p build && cd build
# Use conda's prefix for installation
cmake -DCMAKE_INSTALL_PREFIX="$PREFIX" ..
make
make install
cd "$SRC_DIR"

###############################################################################
# 3) Install or copy your EGAP main script
###############################################################################
# Assuming the main Python script is at the root of your repo: EGAP.py
chmod +x EGAP.py
cp EGAP.py $PREFIX/bin/EGAP