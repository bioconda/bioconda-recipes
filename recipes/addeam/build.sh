#!/bin/bash
set -e  # Exit on error

export CPATH=${PREFIX}/include

#cd "${SRC_DIR}"/addeam || { echo "Folder ${SRC_DIR}/addeam not found"; exit 1; }

#ls -la "${SRC_DIR}/addeam"

# Make sure binaries and scripts are installed in Conda's bin directory
mkdir -p "${PREFIX}/bin"

# Move into the source directory and compile C++ binary
cd submodules/src/

# Avoid conflicts with C++20  
mv "${SRC_DIR}"/submodules/src/lib/libgab/gzstream/version "${SRC_DIR}"submodules/src/lib/libgab/gzstream/version.txt

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


