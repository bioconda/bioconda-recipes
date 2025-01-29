#!/bin/bash
set -e  # Exit on error
set -x  # Print commands for debugging

# Print the current directory for debugging
echo "Current directory: ${PWD}"
ls -lh

# Initialize and update submodules explicitly
git init
git remote add origin https://github.com/CamilaDuitama/muset.git
git fetch origin
git checkout v0.5.1
git submodule init
git submodule update --recursive

# Print submodule status
git submodule status

# Create the output directory
mkdir -p ${PREFIX}/bin

# Create a build directory
mkdir -p build-conda
cd build-conda

ls ../external/*

# Configure the build with CMake
cmake .. -DCONDA_BUILD=ON

# Build the software
make -j${CPU_COUNT}

#Go back to source directory
cd ..

echo "Current directory: ${PWD}"
ls -lh

cp ./bin/kmat_tools ${PREFIX}/bin
cp ./bin/muset-kmtricks ${PREFIX}/bin
cp ./bin/muset ${PREFIX}/bin
cp ./bin/muset_pa ${PREFIX}/bin