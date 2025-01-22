#!/bin/bash
set -e
set -x

# Force verbose output
echo "BIOCONDA BUILD STARTING"
echo "Current directory: $(pwd)"
echo "SRC_DIR: ${SRC_DIR}"
echo "PREFIX: ${PREFIX}"

# Rest of your original build script
mkdir -p ${PREFIX}/bin

mkdir build-conda
cd build-conda

echo "Current directory: ${PWD}"
ls -lh

cmake .. -DCONDA_BUILD=ON
make -j8
cd ..

echo "Current directory: ${PWD}"
ls -lh

cp ./bin/kmat_tools ${PREFIX}/bin
cp ./bin/muset ${PREFIX}/bin
cp ./bin/muset_pa ${PREFIX}/bin

echo "BUILD COMPLETED SUCCESSFULLY"