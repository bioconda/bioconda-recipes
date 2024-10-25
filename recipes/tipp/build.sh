#!/bin/bash

# Exit on any error
set -ex

# Initialize and update all submodules
git submodule update --init

# Define variables for directories
KMC_DIR="src/kmc3"

# Unset Conda-specific environment variables during KMC build
OLD_PREFIX=$PREFIX
unset PREFIX
unset CONDA_PREFIX

# Enter the KMC directory, initialize and update its submodule
cd "$KMC_DIR"
git submodule update --init

# Explicitly build Cloudflare's zlib to ensure it's used in KMC build
cd 3rd_party/cloudflare
./configure
make libz.a

# Go back to KMC directory
cd ../..

# Set flags to use Cloudflare zlib
CFLAGS="-I$(pwd)/3rd_party/cloudflare"
LDFLAGS="-L$(pwd)/3rd_party/cloudflare"
export CFLAGS LDFLAGS

# Build KMC with the correct zlib
make -j"${CPU_COUNT}"

# Unset the flags after the KMC build to prevent issues later
unset CFLAGS
unset LDFLAGS

# Restore the environment variables
export PREFIX=$OLD_PREFIX
export CONDA_PREFIX=$OLD_PREFIX

# Go back to the src directory
cd ../..

# Build seqtk
SEQTK_DIR="src/seqtk"
cd "$SEQTK_DIR"
make -j"${CPU_COUNT}"

# Go back to the src directory
cd ..
echo "we crossed this 1"
# Compile the readskmercount program, ensuring paths to KMC
#g++ -v -o readskmercount -I./kmc3 -L./kmc3/bin -lkmc_core -pthread

# Compile readskmercount as an object first if it doesn't have a main
g++ -c readskmercount.opt.cpp -I./kmc3

echo "we crossed this 2"
# Then link it to create the executable
g++ -o readskmercount readskmercount.opt.o -L./kmc3/bin -lkmc_core -pthread


echo "Installation completed successfully."


#CURRENT_PATH=$(pwd)/src
#export PATH=$CURRENT_PATH:$PATH
#export PATH=$CURRENT_PATH/seqtk:$PATH
# Copy everything to the Conda environments bin directory to ensure they're accessible
echo "Copying binaries to PREFIX..."
cp -r * $PREFIX/bin/ || { echo "Failed to copy binaries to PREFIX"; exit 1; }

echo "Installation completed successfully."
echo "Copying activation and deactivation scripts..."
mkdir -p $PREFIX/etc/conda/activate.d
mkdir -p $PREFIX/etc/conda/deactivate.d



echo 'export CURRENT_PATH=$CONDA_PREFIX/bin' >$PREFIX/etc/conda/activate.d/tipp.sh

# Add TIPP and related tools to the PATH
echo 'export PATH=$CURRENT_PATH:$PATH' >> $PREFIX/etc/conda/activate.d/tipp.sh
echo 'export PATH=$CURRENT_PATH/seqtk:$PATH' >> $PREFIX/etc/conda/activate.d/tipp.sh
echo 'export PATH=$CURRENT_PATH/kmc3/bin:$PATH' >> $PREFIX/etc/conda/activate.d/tipp.sh


echo 'export PATH=$(echo $PATH | sed -e "s|$CONDA_PREFIX/bin:||g")' >$PREFIX/etc/conda/deactivate.d/tipp.sh
