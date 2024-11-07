#!/bin/bash

# Exit on any error
set -ex

# Initialize and update all submodules
#git submodule update --init

# Define variables for directories
KMC_DIR="src/kmc3"

# Unset Conda-specific environment variables during KMC build
OLD_PREFIX=$PREFIX
unset PREFIX
unset CONDA_PREFIX

# Enter the KMC directory, initialize and update its submodule
cd "$KMC_DIR"
#git submodule update --init

# Explicitly build Cloudflares zlib to ensure it's used in KMC build
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
make  -j "${CPU_COUNT}"

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
make  -j "${CPU_COUNT}"

# Go back to the src directory
cd ..

# Compile readskmercount as an object first if it doesn't have a main
${CXX}  -c readskmercount.opt.cpp -I./kmc3

# Then link it to create the executable
${CXX}  -o readskmercount readskmercount.opt.o -L./kmc3/bin -lkmc_core -pthread

# Copy everything to the Conda environments bin directory to ensure they're accessible
echo "Copying binaries to PREFIX..."
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/bin/kmc3
mkdir -p $PREFIX/bin/seqtk
cp graph.plot.r readskmercount TIPP.pl TIPP_polish.pl html2repeatbed.pl MSA.plot.r TIPP_plastid.pl TIPP_telomere_backup.pl readskmercount.cpp telomeres.visulization.r TIPP_plastid.v2.1.pl TIPP_telomere.pl "$PREFIX/bin/" || { echo "Failed to copy specific binaries to PREFIX"; exit 1; }
cp -r kmc3/bin $PREFIX/bin/kmc3/
cp seqtk/seqtk $PREFIX/bin/seqtk/

echo "Installation completed successfully."
echo "Copying activation and deactivation scripts..."
mkdir -p $PREFIX/etc/conda/activate.d
mkdir -p $PREFIX/etc/conda/deactivate.d

# Add TIPP and related tools to the PATH

cat << EOF > $PREFIX/etc/conda/activate.d/tipp.sh
# Set the current path to the conda environment's bin directory
export CURRENT_PATH=\$CONDA_PREFIX/bin

# Add TIPP and related tools to the PATH
export PATH=\$CURRENT_PATH:\$PATH
export PATH=\$CURRENT_PATH/seqtk:\$PATH
export PATH=\$CURRENT_PATH/kmc3/bin:\$PATH
EOF

cat << EOF > $PREFIX/etc/conda/deactivate.d/tipp.sh
# Remove the current conda environment's bin directory from PATH
export PATH=\$(echo \$PATH | sed -e "s|$CONDA_PREFIX/bin:||g")
EOF

echo "Installation completed successfully."
