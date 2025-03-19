#!/bin/bash
set -e  # Exit on error

# fix zlib error
export CPATH=${PREFIX}/include

# Make sure binaries and scripts are installed in Conda's bin directory
mkdir -p "${PREFIX}/bin"

# Move into the source directory and compile C++ binary
cd submodules/src/
make clean
make
mv bam2prof "${PREFIX}/bin/"
chmod +x "${PREFIX}/bin/bam2prof"
cd ../..

# Ensure Python scripts are installed correctly
cp addeam-bam2prof.py addeam-cluster.py "${PREFIX}/bin/"
chmod +x "${PREFIX}/bin/addeam-bam2prof.py" "${PREFIX}/bin/addeam-cluster.py"

# Add ${PREFIX}/bin to PATH so tests can find the executables
export PATH="${PREFIX}/bin:$PATH"


